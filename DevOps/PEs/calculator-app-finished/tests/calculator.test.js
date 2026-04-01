const request = require('supertest')
const app = require('../app');

describe("Test if frontend server works", () => {
    test("It should respond with statuscode 200", async () => {
      const response = await request(app).get("/");
      expect(response.statusCode).toBe(200);
    });
});

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

describe("Test the subtract path", () => {
  test("It should response the GET method", async () => {
    const response = await request(app).get("/calc/subtract/1/2");
    expect(response.statusCode).toBe(200);
  });
});

describe("Test the subtract logic", () => {
  test("It should respond with '3'", async () => {
    const response = await request(app).get("/calc/subtract/5/2");
    expect(response.body).toBe('3');
  });
});

describe("Test the multiply path", () => {
  test("It should response the GET method", async () => {
    const response = await request(app).get("/calc/multiply/1/2");
    expect(response.statusCode).toBe(200);
  });
});

describe("Test the multiply logic", () => {
  test("It should respond with '10'", async () => {
    const response = await request(app).get("/calc/multiply/5/2");
    expect(response.body).toBe('10');
  });
});

describe("Test the divide path", () => {
  test("It should response the GET method", async () => {
    const response = await request(app).get("/calc/divide/1/2");
    expect(response.statusCode).toBe(200);
  });
});

describe("Test the divide logic", () => {
  test("It should respond with '5'", async () => {
    const response = await request(app).get("/calc/divide/10/2");
    expect(response.body).toBe('5');
  });
});