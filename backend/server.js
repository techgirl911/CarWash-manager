const express = require('express');
const cors = require('cors');
require('dotenv').config();
const spacesRoutes = require('./routes/spaces');
const authRoutes = require('./routes/auth');

const app = express();

app.use(cors());
app.use(express.json());

// Test route
app.get('/', (req, res) => {
  res.json({ message: "Lulu's Car Wash API is running 🚗💦" });
});

// Auth routes
app.use('/api/auth', authRoutes);
app.use('/api/spaces', spacesRoutes);
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});