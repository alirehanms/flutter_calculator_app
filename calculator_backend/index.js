
require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = 3000;

// ******************************************************************
// IMPORTANT: Replace with your PostgreSQL connection details
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});
// ******************************************************************

app.use(express.json());

// Endpoint to get calculation history
app.get('/history', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM history ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

// Endpoint to save a new calculation
app.post('/history', async (req, res) => {
  try {
    const { expression, result } = req.body;
    if (!expression || !result) {
      return res.status(400).send('Expression and result are required');
    }
    const newEntry = await pool.query(
      'INSERT INTO history (expression, result) VALUES ($1, $2) RETURNING *',
      [expression, result]
    );
    res.status(201).json(newEntry.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
