const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/authMiddleware');

// ── GET ALL BAYS ──────────────────────────────────────────
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [bays] = await pool.query('SELECT * FROM bays ORDER BY bay_number');
    res.json(bays);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ── UPDATE BAY STATUS ─────────────────────────────────────
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { status, car_plate, service_type } = req.body;

    if (status === 'empty') {
      await pool.query(
        'UPDATE bays SET status = ?, car_plate = NULL, service_type = NULL WHERE id = ?',
        [status, id]
      );
    } else {
      await pool.query(
        'UPDATE bays SET status = ?, car_plate = ?, service_type = ? WHERE id = ?',
        [status, car_plate || 'New Car', service_type || 'Basic Wash', id]
      );
    }

    res.json({ message: 'Bay updated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;