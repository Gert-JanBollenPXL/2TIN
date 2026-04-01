const request = require('supertest');
const app = require('../app');

describe("Test if frontend server works", () => {
    test("It should respond with statuscode 200", async () => {
      const response = await request(app).get("/");
      expect(response.statusCode).toBe(200);
    });
});

// tests for adding
describe("Test the add path", () => {
    test("It should response the GET method", async () => {
      const response = await request(app).get("/calc/add/1/2");
      expect(response.statusCode).toBe(200);
    });
});

describe("Test the add logic", () => {
    test("It should respond with '7'", async () => {
      const response = await request(app).get("/calc/add/5/2");
      expect(response.body).toBe('7');
    });
});

// tests for multiplying
describe("Test the multiply path", () => {
    test("It should response the GET method", async () => {
      const response = await request(app).get("/calc/multiply/5/5");
      expect(response.statusCode).toBe(200);
    });
});

describe("Test the multiply logic", () => {
    test("It should respond with '25'", async () => {
      const response = await request(app).get("/calc/multiply/5/5");
      expect(response.body).toBe('25');
    });
});

// tests for subtracting
describe("Test the subtract path", () => {
    test("It should response the GET method", async () => {
      const response = await request(app).get("/calc/subtract/2/1");
      expect(response.statusCode).toBe(200);
    });
});

describe("Test the subtract logic", () => {
    test("It should respond with '3'", async () => {
      const response = await request(app).get("/calc/subtract/5/2");
      expect(response.body).toBe('3');
    });
});

// tests for dividing
describe("Test the divide path", () => {
    test("It should response the GET method", async () => {
      const response = await request(app).get("/calc/divide/35/5");
      expect(response.statusCode).toBe(200);
    });
});

describe("Test the divide logic", () => {
    test("It should respond with '7'", async () => {
      const response = await request(app).get("/calc/divide/35/5");
      expect(response.body).toBe('7');
    });
});

// tests for power-of
describe("Test the power-of path", () => {
    test("It should response the GET method", async () => {
        const response = await request(app).get("/calc/power-of/1/2");
        expect(response.statusCode).toBe(200);
    });
});

describe("Test the power-of logic", () => {
    test("It should respond with '9'", async () => {
        const response = await request(app).get("/calc/power-of/3/2");
        expect(response.body).toBe('9');
    });
});