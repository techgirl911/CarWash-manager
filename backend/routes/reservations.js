const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const { authMiddleware, adminOnly } = require('../middleware/authMiddleware');

// ── CREATE RESERVATION (customer) ──────────────────────────
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { car_plate, service_type, price, reservation_time } = req.body;
    const customer_id = req.user.id;

    if (!car_plate || !service_type || !price || !reservation_time) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    await pool.query(
      'INSERT INTO reservations (customer_id, car_plate, service_type, price, reservation_time) VALUES (?, ?, ?, ?, ?)',
      [customer_id, car_plate, service_type, price, reservation_time]
    );

    res.status(201).json({ message: 'Reservation created' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ── GET MY RESERVATIONS (customer) ─────────────────────────
router.get('/my', authMiddleware, async (req, res) => {
  try {
    const [reservations] = await pool.query(
      'SELECT * FROM reservations WHERE customer_id = ? ORDER BY created_at DESC',
      [req.user.id]
    );
    res.json(reservations);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ── GET ALL RESERVATIONS (admin) ───────────────────────────
router.get('/', authMiddleware, adminOnly, async (req, res) => {
  try {
    const [reservations] = await pool.query(`
      SELECT r.*, u.name AS customer_name 
      FROM reservations r 
      JOIN users u ON r.customer_id = u.id 
      ORDER BY r.created_at DESC
    `);
    res.json(reservations);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ── CANCEL RESERVATION (customer) ──────────────────────────
router.put('/:id/cancel', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await pool.query(
      'SELECT * FROM reservations WHERE id = ? AND customer_id = ?',
      [id, req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Reservation not found' });
    }

    if (rows[0].status !== 'pending') {
      return res.status(400).json({ message: 'Only pending reservations can be cancelled' });
    }

    await pool.query('UPDATE reservations SET status = ? WHERE id = ?', ['cancelled', id]);

    res.json({ message: 'Reservation cancelled' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ── UPDATE RESERVATION STATUS (admin) ──────────────────────
router.put('/:id/status', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { id } = req.params;
    const { status, bay_id } = req.body;

    await pool.query('UPDATE reservations SET status = ? WHERE id = ?', [status, id]);

    // If marking as active, occupy the chosen bay
    if (status === 'active' && bay_id) {
      const [resv] = await pool.query('SELECT car_plate, service_type FROM reservations WHERE id = ?', [id]);
      await pool.query(
        'UPDATE bays SET status = ?, car_plate = ?, service_type = ? WHERE id = ?',
        ['occupied', resv[0].car_plate, resv[0].service_type, bay_id]
      );
      await pool.query('UPDATE reservations SET bay_id = ? WHERE id = ?', [bay_id, id]);
    }

    // If marking as done or cancelled, free up the bay
    if ((status === 'done' || status === 'cancelled')) {
      const [resv] = await pool.query('SELECT bay_id FROM reservations WHERE id = ?', [id]);
      if (resv[0]?.bay_id) {
        await pool.query(
          'UPDATE bays SET status = ?, car_plate = NULL, service_type = NULL WHERE id = ?',
          ['empty', resv[0].bay_id]
        );
      }
    }

    res.json({ message: 'Status updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ── GET TODAY'S COUNT (for dashboard stats) ────────────────
router.get('/stats/today', authMiddleware, async (req, res) => {
  try {
    const [result] = await pool.query(`
      SELECT COUNT(*) as count FROM reservations 
      WHERE DATE(reservation_time) = CURDATE() AND status != 'cancelled'
    `);
    res.json({ count: result[0].count });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;