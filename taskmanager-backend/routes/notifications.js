// routes/notifications.js

const express = require('express');
const router = express.Router();
const db = require('../config/db');
const authMiddleware = require('../middleware/auth');

// All routes require authentication
router.use(authMiddleware);

// GET /api/notifications
router.get('/', async (req, res) => {
  try {
    const userId = req.userId; // ✅ fixed: matches auth middleware

    const [notifications] = await db.query(
      `SELECT id, title, message, is_read, created_at
       FROM notifications
       WHERE user_id = ?
       ORDER BY created_at DESC`,
      [userId]
    );

    return res.status(200).json({ statusCode: 200, notifications });
  } catch (err) {
    console.error('Get notifications error:', err);
    return res.status(500).json({ statusCode: 500, message: 'Server error while fetching notifications.' });
  }
});

// POST /api/notifications  ✅ NEW — create notification from Flutter
router.post('/', async (req, res) => {
  try {
    const userId = req.userId;
    const { title, message } = req.body;

    if (!title || !message) {
      return res.status(400).json({ statusCode: 400, message: 'Title and message are required.' });
    }

    const [result] = await db.query(
      `INSERT INTO notifications (user_id, title, message)
       VALUES (?, ?, ?)`,
      [userId, title, message]
    );

    const [newNotification] = await db.query(
      `SELECT id, title, message, is_read, created_at
       FROM notifications
       WHERE id = ?`,
      [result.insertId]
    );

    return res.status(201).json({
      statusCode: 201,
      message: 'Notification created.',
      notification: newNotification[0],
    });
  } catch (err) {
    console.error('Create notification error:', err);
    return res.status(500).json({ statusCode: 500, message: 'Server error while creating notification.' });
  }
});

// ✅ IMPORTANT: /read-all MUST come BEFORE /:id/read
// otherwise Express matches "read-all" as an :id param

// PATCH /api/notifications/read-all
router.patch('/read-all', async (req, res) => {
  try {
    const userId = req.userId; // ✅ fixed

    await db.query(
      `UPDATE notifications SET is_read = 1 WHERE user_id = ?`,
      [userId]
    );

    return res.status(200).json({ statusCode: 200, message: 'All notifications marked as read.' });
  } catch (err) {
    console.error('Mark all read error:', err);
    return res.status(500).json({ statusCode: 500, message: 'Server error while marking all as read.' });
  }
});

// PATCH /api/notifications/:id/read
router.patch('/:id/read', async (req, res) => {
  try {
    const userId = req.userId; // ✅ fixed
    const notificationId = req.params.id;

    const [result] = await db.query(
      `UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?`,
      [notificationId, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ statusCode: 404, message: 'Notification not found.' });
    }

    return res.status(200).json({ statusCode: 200, message: 'Notification marked as read.' });
  } catch (err) {
    console.error('Mark read error:', err);
    return res.status(500).json({ statusCode: 500, message: 'Server error while marking as read.' });
  }
});

// DELETE /api/notifications/:id
router.delete('/:id', async (req, res) => {
  try {
    const userId = req.userId;
    const notificationId = req.params.id;

    const [result] = await db.query(
      `DELETE FROM notifications WHERE id = ? AND user_id = ?`,
      [notificationId, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ statusCode: 404, message: 'Notification not found.' });
    }

    return res.status(200).json({ statusCode: 200, message: 'Notification deleted.' });
  } catch (err) {
    console.error('Delete notification error:', err);
    return res.status(500).json({ statusCode: 500, message: 'Server error while deleting notification.' });
  }
});

// DELETE /api/notifications  — clear all for user
router.delete('/', async (req, res) => {
  try {
    const userId = req.userId;

    await db.query(`DELETE FROM notifications WHERE user_id = ?`, [userId]);

    return res.status(200).json({ statusCode: 200, message: 'All notifications cleared.' });
  } catch (err) {
    console.error('Clear notifications error:', err);
    return res.status(500).json({ statusCode: 500, message: 'Server error while clearing notifications.' });
  }
});

module.exports = router;