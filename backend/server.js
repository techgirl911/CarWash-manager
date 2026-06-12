const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const spacesRoutes = require('./routes/spaces');
const drinksRoutes = require('./routes/drinks');
const reservationsRoutes = require('./routes/reservations');
const financeRoutes = require('./routes/finance');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: "Lulu's Car Wash API is running" });
});

app.use('/api/auth', authRoutes);
app.use('/api/spaces', spacesRoutes);
app.use('/api/drinks', drinksRoutes);
app.use('/api/reservations', reservationsRoutes);
app.use('/api/finance', financeRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});