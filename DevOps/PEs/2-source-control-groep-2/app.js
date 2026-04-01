const express = require('express');
const routes = require('./routes');

const app = express();

app.use(express.static('public'));
app.use('/calc', routes);

module.exports = app    