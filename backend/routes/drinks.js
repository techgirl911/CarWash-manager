const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/authMiddleware');

// ── GET ALL DRINKS ────────────────────────────────────────
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [drinks] = await pool.query('SELECT * FROM drinks ORDER BY name');
    res.json(drinks);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ── ADD NEW DRINK ─────────────────────────────────────────
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { name, stock, unit_price, low_stock_threshold } = req.body;

    if (!name || unit_price === undefined) {
      return res.status(400).json({ message: 'Name and price are required' });
    }

    await pool.query(
      'INSERT INTO drinks (name, stock, unit_price, low_stock_threshold) VALUES (?, ?, ?, ?)',
      [name, stock || 0, unit_price, low_stock_threshold || 5]
    );

    res.status(201).json({ message: 'Drink added successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ── UPDATE STOCK (+/-) ────────────────────────────────────
router.put('/:id/stock', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { delta } = req.body; // +1 or -1

    const [drinks] = await pool.query('SELECT stock FROM drinks WHERE id = ?', [id]);
    if (drinks.length === 0) {
      return res.status(404).json({ message: 'Drink not found' });
    }

    let newStock = drinks[0].stock + delta;
    if (newStock < 0) newStock = 0;

    await pool.query('UPDATE drinks SET stock = ? WHERE id = ?', [newStock, id]);

    res.json({ message: 'Stock updated', stock: newStock });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;