const express = require('express');
const axios = require('axios');
const app = express();

const FLASK_URL = process.env.FLASK_URL || 'http://localhost:5000';

app.get('/', async (req, res) => {
  try {
    const response = await axios.get(`${FLASK_URL}/api/message`);
    res.send(`<h1>${response.data.message}</h1>`);
  } catch (err) {
    res.send('Error reaching backend: ' + err.message);
  }
});

app.listen(3000, () => console.log('Express running on port 3000'));
