const express = require('express');
const router = express.Router();

// Provide an /add endpoint followed by 2 values that will be added. Result is returned
// in JSON format
router.get('/add/:num1/:num2', function (req, res) {
    var num1 = parseInt(req.params.num1)
    var num2 = parseInt(req.params.num2)
    var sum = (num1 + num2).toString()
    res.json(sum)
})

// Provide a /multiply endpoint followed by 2 values that will be multiplied. Result is returned
// in JSON format
router.get('/multiply/:num1/:num2', function (req, res) {
    var num1 = parseInt(req.params.num1)
    var num2 = parseInt(req.params.num2)
    var multiplication = (num1 * num2).toString()
    res.json(multiplication)
})

// Provide a /subtract endpoint followed by 2 values that will be subtracted. Result is returned
// in JSON format
router.get('/subtract/:num1/:num2', function (req, res) {
    var num1 = parseInt(req.params.num1)
    var num2 = parseInt(req.params.num2)
    var difference = (num1 - num2).toString()
    res.json(difference)
})

// Provide a /divide endpoint followed by 2 values that will be divided. Result is returned
// in JSON format
router.get('/divide/:num1/:num2', function (req, res) {
    var num1 = parseInt(req.params.num1)
    var num2 = parseInt(req.params.num2)
    var result = (num1 / num2).toString()
    res.json(result)
})

// Provide a /power-of endpoint followed by 2 values. Result of num1^num2 is returned
// in JSON format
router.get('/power-of/:num1/:num2', function (req, res) {
    var num1 = parseInt(req.params.num1)
    var num2 = parseInt(req.params.num2)
    var powerOf = (Math.pow(num1, num2)).toString()
    res.json(powerOf)
})

module.exports = router