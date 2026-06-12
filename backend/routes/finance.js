const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const { authMiddleware, adminOnly } = require('../middleware/authMiddleware');

// ── GET FINANCE HISTORY (admin) ────────────────────────────
router.get('/', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM daily_finance ORDER BY entry_date DESC LIMIT 30'
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ── ADD / UPDATE TODAY'S ENTRY (admin) ─────────────────────
router.post('/', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { wash_income, drink_income, expenses } = req.body;
    const profit = (wash_income || 0) + (drink_income || 0) - (expenses || 0);

    // Upsert: if today's entry exists, update it; else insert
    await pool.query(
      `INSERT INTO daily_finance (entry_date, wash_income, drink_income, expenses, profit)
       VALUES (CURDATE(), ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         wash_income = wash_income + ?,
         drink_income = drink_income + ?,
         expenses = expenses + ?,
         profit = profit + ?`,
      [wash_income || 0, drink_income || 0, expenses || 0, profit,
       wash_income || 0, drink_income || 0, expenses || 0, profit]
    );

    res.status(201).json({ message: 'Entry saved' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ── GET TODAY'S PROFIT (for dashboard stats) ───────────────
router.get('/today', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM daily_finance WHERE entry_date = CURDATE()'
    );
    res.json(rows[0] || { wash_income: 0, drink_income: 0, expenses: 0, profit: 0 });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;