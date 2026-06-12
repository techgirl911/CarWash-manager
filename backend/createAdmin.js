const bcrypt = require('bcryptjs');
const pool = require('./config/db');
require('dotenv').config();

async function createAdmin() {
  const name = 'Lulu Admin';
  const email = 'admin@luluscarwash.com';
  const password = 'admin123'; // change this later!
  const hashedPassword = await bcrypt.hash(password, 10);

  try {
    await pool.query(
      'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
      [name, email, hashedPassword, 'admin']
    );
    console.log('✅ Admin created successfully!');
    console.log('Email:', email);
    console.log('Password:', password);
  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    process.exit();
  }
}

createAdmin();