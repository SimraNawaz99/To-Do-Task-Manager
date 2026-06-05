// routes/tasks.js

const express = require('express');
const db = require('../config/db');
const authMW = require('../middleware/auth');

const router = express.Router();

router.use(authMW);

const VALID_PRIORITIES = ['High', 'Medium', 'Low'];

function isValidDate(dateString) {
  if (!dateString) return false;
  const regex = /^\d{4}-\d{2}-\d{2}$/;
  if (!regex.test(dateString)) return false;
  const date = new Date(dateString);
  return !Number.isNaN(date.getTime());
}

async function createNotification(userId, title, message) {
  try {
    console.log('Inserting notification | userId:', userId, '| title:', title);
    const [result] = await db.query(
      `INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)`,
      [userId, title, message]
    );
    console.log('Notification inserted | id:', result.insertId);
  } catch (err) {
    console.error('Create notification error:', err.message);
  }
}

// GET /api/tasks
router.get('/', async (req, res) => {
  const { status, priority, category, search } = req.query;

  let query = `
    SELECT id, user_id, title, priority, category, due_date, is_completed
    FROM tasks
    WHERE user_id = ?
  `;
  const params = [req.userId];

  if (status === 'Completed') query += ' AND is_completed = 1';
  else if (status === 'Pending') query += ' AND is_completed = 0';

  if (priority && priority !== 'All') {
    if (!VALID_PRIORITIES.includes(priority)) {
      return res.status(400).json({ message: 'Invalid priority filter.' });
    }
    query += ' AND priority = ?';
    params.push(priority);
  }

  if (category && category !== 'All') {
    query += ' AND category = ?';
    params.push(category);
  }

  if (search && search.trim() !== '') {
    query += ' AND title LIKE ?';
    params.push(`%${search.trim()}%`);
  }

  query += ' ORDER BY id DESC';

  try {
    const [rows] = await db.query(query, params);
    return res.status(200).json({ tasks: rows });
  } catch (err) {
    console.error('Get tasks error:', err);
    return res.status(500).json({ message: 'Server error while fetching tasks.' });
  }
});

// GET /api/tasks/:id
router.get('/:id', async (req, res) => {
  const taskId = req.params.id;
  try {
    const [rows] = await db.query(
      `SELECT id, user_id, title, priority, category, due_date, is_completed
       FROM tasks WHERE id = ? AND user_id = ?`,
      [taskId, req.userId]
    );
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Task not found.' });
    }
    return res.status(200).json({ task: rows[0] });
  } catch (err) {
    console.error('Get task error:', err);
    return res.status(500).json({ message: 'Server error while fetching task.' });
  }
});

// POST /api/tasks
router.post('/', async (req, res) => {
  const { title, priority, category, due_date } = req.body;

  if (!title || title.trim() === '') {
    return res.status(400).json({ message: 'Title is required.' });
  }
  if (!due_date || !isValidDate(due_date)) {
    return res.status(400).json({ message: 'Valid due date is required.' });
  }

  const taskTitle    = title.trim();
  const taskPriority = VALID_PRIORITIES.includes(priority) ? priority : 'Medium';
  const taskCategory = category && category.trim() !== '' ? category.trim() : 'General';

  try {
    const [result] = await db.query(
      `INSERT INTO tasks (user_id, title, priority, category, due_date)
       VALUES (?, ?, ?, ?, ?)`,
      [req.userId, taskTitle, taskPriority, taskCategory, due_date]
    );

    const [newTask] = await db.query(
      `SELECT id, user_id, title, priority, category, due_date, is_completed
       FROM tasks WHERE id = ? AND user_id = ?`,
      [result.insertId, req.userId]
    );

    // ✅ No emojis — plain text only
    await createNotification(
      req.userId,
      'New Task Added',
      `"${taskTitle}" has been added to your tasks.`
    );

    return res.status(201).json({ message: 'Task created.', task: newTask[0] });
  } catch (err) {
    console.error('Create task error:', err);
    return res.status(500).json({ message: 'Server error while creating task.' });
  }
});

// PUT /api/tasks/:id
router.put('/:id', async (req, res) => {
  const taskId = req.params.id;
  const { title, priority, category, due_date, is_completed } = req.body;

  try {
    const [existing] = await db.query(
      `SELECT id, is_completed, title FROM tasks WHERE id = ? AND user_id = ?`,
      [taskId, req.userId]
    );
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Task not found.' });
    }

    const fields = [];
    const values = [];

    if (title !== undefined)    { fields.push('title = ?');    values.push(title.trim()); }
    if (priority !== undefined) { fields.push('priority = ?'); values.push(priority); }
    if (category !== undefined) { fields.push('category = ?'); values.push(category.trim()); }
    if (due_date !== undefined) { fields.push('due_date = ?'); values.push(due_date); }

    if (is_completed !== undefined) {
      const newStatus = is_completed === true || is_completed === 1 || is_completed === '1' ? 1 : 0;
      fields.push('is_completed = ?');
      values.push(newStatus);

      // ✅ No emojis
      await createNotification(
        req.userId,
        newStatus ? 'Task Completed' : 'Task Reopened',
        `"${existing[0].title}" has been marked as ${newStatus ? 'completed' : 'pending'}.`
      );
    } else if (fields.length > 0) {
      // ✅ No emojis
      await createNotification(
        req.userId,
        'Task Updated',
        `"${existing[0].title}" has been updated.`
      );
    }

    if (fields.length === 0) {
      return res.status(400).json({ message: 'No fields provided to update.' });
    }

    values.push(taskId, req.userId);
    await db.query(
      `UPDATE tasks SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
      values
    );

    const [updated] = await db.query(
      `SELECT id, user_id, title, priority, category, due_date, is_completed
       FROM tasks WHERE id = ? AND user_id = ?`,
      [taskId, req.userId]
    );

    return res.status(200).json({ message: 'Task updated.', task: updated[0] });
  } catch (err) {
    console.error('Update task error:', err);
    return res.status(500).json({ message: 'Server error while updating task.' });
  }
});

// PATCH /api/tasks/:id/toggle
router.patch('/:id/toggle', async (req, res) => {
  const taskId = req.params.id;

  try {
    const [existing] = await db.query(
      `SELECT id, is_completed, title FROM tasks WHERE id = ? AND user_id = ?`,
      [taskId, req.userId]
    );
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Task not found.' });
    }

    const newStatus = existing[0].is_completed ? 0 : 1;

    await db.query(
      `UPDATE tasks SET is_completed = ? WHERE id = ? AND user_id = ?`,
      [newStatus, taskId, req.userId]
    );

    // ✅ No emojis
    await createNotification(
      req.userId,
      newStatus ? 'Task Completed' : 'Task Reopened',
      `"${existing[0].title}" has been marked as ${newStatus ? 'completed' : 'pending'}.`
    );

    const [updated] = await db.query(
      `SELECT id, user_id, title, priority, category, due_date, is_completed
       FROM tasks WHERE id = ? AND user_id = ?`,
      [taskId, req.userId]
    );

    return res.status(200).json({
      message: `Task marked as ${newStatus ? 'completed' : 'pending'}.`,
      is_completed: newStatus,
      task: updated[0],
    });
  } catch (err) {
    console.error('Toggle task error:', err);
    return res.status(500).json({ message: 'Server error while toggling task.' });
  }
});

// DELETE /api/tasks/:id
router.delete('/:id', async (req, res) => {
  const taskId = req.params.id;

  try {
    const [existing] = await db.query(
      `SELECT id, title FROM tasks WHERE id = ? AND user_id = ?`,
      [taskId, req.userId]
    );
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Task not found.' });
    }

    await db.query(
      `DELETE FROM tasks WHERE id = ? AND user_id = ?`,
      [taskId, req.userId]
    );

    // ✅ No emojis
    await createNotification(
      req.userId,
      'Task Deleted',
      `"${existing[0].title}" has been deleted.`
    );

    return res.status(200).json({ message: 'Task deleted successfully.' });
  } catch (err) {
    console.error('Delete task error:', err);
    return res.status(500).json({ message: 'Server error while deleting task.' });
  }
});

module.exports = router;