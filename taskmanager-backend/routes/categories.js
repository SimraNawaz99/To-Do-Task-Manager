// routes/categories.js

const express = require('express');
const db = require('../config/db');
const authMW = require('../middleware/auth');

const router = express.Router();

router.use(authMW);

const DEFAULT_CATEGORIES = ['General', 'Study', 'Work', 'Personal'];


// GET /api/categories
// Get all categories for logged-in user
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id, user_id, name
       FROM categories
       WHERE user_id = ?
       ORDER BY name ASC`,
      [req.userId]
    );

    return res.status(200).json({
      categories: rows,
    });

  } catch (err) {
    console.error('Get categories error:', err);
    return res.status(500).json({
      message: 'Server error while fetching categories.',
    });
  }
});


// POST /api/categories
// Add new category
router.post('/', async (req, res) => {
  const { name } = req.body;

  if (!name || name.trim() === '') {
    return res.status(400).json({
      message: 'Category name is required.',
    });
  }

  const categoryName = name.trim();

  if (categoryName.length > 100) {
    return res.status(400).json({
      message: 'Category name cannot be more than 100 characters.',
    });
  }

  if (categoryName.toLowerCase() === 'all') {
    return res.status(400).json({
      message: 'Category name "All" is reserved and cannot be used.',
    });
  }

  try {
    const [existing] = await db.query(
      `SELECT id
       FROM categories
       WHERE user_id = ? AND LOWER(name) = LOWER(?)`,
      [req.userId, categoryName]
    );

    if (existing.length > 0) {
      return res.status(409).json({
        message: 'Category already exists.',
      });
    }

    const [result] = await db.query(
      `INSERT INTO categories (user_id, name)
       VALUES (?, ?)`,
      [req.userId, categoryName]
    );

    const [newCategory] = await db.query(
      `SELECT id, user_id, name
       FROM categories
       WHERE id = ? AND user_id = ?`,
      [result.insertId, req.userId]
    );

    return res.status(201).json({
      message: 'Category added.',
      category: newCategory[0],
    });

  } catch (err) {
    console.error('Add category error:', err);
    return res.status(500).json({
      message: 'Server error while adding category.',
    });
  }
});


// DELETE /api/categories/:id
// Delete category by ID
router.delete('/:id', async (req, res) => {
  const categoryId = req.params.id;

  const connection = await db.getConnection();

  try {
    await connection.beginTransaction();

    const [existing] = await connection.query(
      `SELECT id, name
       FROM categories
       WHERE id = ? AND user_id = ?`,
      [categoryId, req.userId]
    );

    if (existing.length === 0) {
      await connection.rollback();

      return res.status(404).json({
        message: 'Category not found.',
      });
    }

    const category = existing[0];

    if (DEFAULT_CATEGORIES.includes(category.name)) {
      await connection.rollback();

      return res.status(400).json({
        message: 'Default categories cannot be deleted.',
      });
    }

    const [updateResult] = await connection.query(
      `UPDATE tasks
       SET category = 'General'
       WHERE user_id = ? AND category = ?`,
      [req.userId, category.name]
    );

    await connection.query(
      `DELETE FROM categories
       WHERE id = ? AND user_id = ?`,
      [categoryId, req.userId]
    );

    await connection.commit();

    return res.status(200).json({
      message: 'Category deleted.',
      deletedCategory: category,
      movedTasks: updateResult.affectedRows,
    });

  } catch (err) {
    await connection.rollback();

    console.error('Delete category error:', err);
    return res.status(500).json({
      message: 'Server error while deleting category.',
    });

  } finally {
    connection.release();
  }
});


module.exports = router;