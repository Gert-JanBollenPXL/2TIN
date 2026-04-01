const express = require('express');
const router = express.Router();

router.get('/add/:num1/:num2', function (req, res) {
  let num1 = parseInt(req.params.num1)
  let num2 = parseInt(req.params.num2)
  let sum = (num1 + num2).toString()
  res.json(sum)
})

router.get('/subtract/:num1/:num2', function (req, res) {
  // TODO
  let num1 = parseInt(req.params.num1)
  let num2 = parseInt(req.params.num2)
  let result = (num1 - num2).toString()
  res.json(result)
})

router.get('/multiply/:num1/:num2', function (req, res) {
  // TODO
  let num1 = parseInt(req.params.num1)
  let num2 = parseInt(req.params.num2)
  let result = (num1 * num2).toString()
  res.json(result)
})

router.get('/divide/:num1/:num2', function (req, res) {
  // TODO
  let num1 = parseInt(req.params.num1)
  let num2 = parseInt(req.params.num2)
  let result = (num1 / num2).toString()
  res.json(result)
})


module.exports = router