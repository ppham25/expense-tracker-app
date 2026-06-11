const request = require("supertest");
const jwt = require("jsonwebtoken");

jest.mock("../models/budgetModel", () => ({
  createBudget: jest.fn(),
  getBudgetsByMonth: jest.fn(),
  updateBudget: jest.fn(),
  deleteBudget: jest.fn(),
}));

jest.mock("../models/categoryModel", () => ({
  findCategoryByIdAndUserId: jest.fn(),
  findCategoryByNameAndUserId: jest.fn(),
}));

const app = require("../app");
const budgetModel = require("../models/budgetModel");
const categoryModel = require("../models/categoryModel");

beforeAll(() => {
  process.env.JWT_SECRET = "test_secret";
});

beforeEach(() => {
  jest.clearAllMocks();
});

const getToken = () => jwt.sign({ userId: 1 }, process.env.JWT_SECRET);

describe("Budget API", () => {
  test("Không cho tạo ngân sách nếu thiếu token", async () => {
    const res = await request(app).post("/api/budgets").send({
      categoryId: 3,
      limitAmount: 500,
      month: 5,
      year: 2026,
    });

    expect(res.statusCode).toBe(401);
  });

  test("Không cho tạo ngân sách nếu hạn mức bằng 0", async () => {
    const token = getToken();

    categoryModel.findCategoryByIdAndUserId.mockResolvedValue({
      id: 3,
      user_id: 1,
      name: "leisure",
    });

    const res = await request(app)
      .post("/api/budgets")
      .set("Authorization", `Bearer ${token}`)
      .send({
        categoryId: 3,
        limitAmount: 0,
        month: 5,
        year: 2026,
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toBe(
      "Limit amount must be a number greater than 0",
    );
  });

  test("Không cho tạo ngân sách nếu tháng không hợp lệ", async () => {
    const token = getToken();

    categoryModel.findCategoryByIdAndUserId.mockResolvedValue({
      id: 3,
      user_id: 1,
      name: "leisure",
    });

    const res = await request(app)
      .post("/api/budgets")
      .set("Authorization", `Bearer ${token}`)
      .send({
        categoryId: 3,
        limitAmount: 500,
        month: 13,
        year: 2026,
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toBe("Invalid month or year");
  });

  test("Tạo ngân sách thành công khi dữ liệu hợp lệ", async () => {
    const token = getToken();

    categoryModel.findCategoryByIdAndUserId.mockResolvedValue({
      id: 3,
      user_id: 1,
      name: "leisure",
    });

    budgetModel.createBudget.mockResolvedValue({
      id: 5,
      user_id: 1,
      categoryId: 3,
      category: "leisure",
      limitAmount: 500,
      month: 5,
      year: 2026,
    });

    const res = await request(app)
      .post("/api/budgets")
      .set("Authorization", `Bearer ${token}`)
      .send({
        categoryId: 3,
        limitAmount: 500,
        month: 5,
        year: 2026,
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.message).toBe("Budget created");
    expect(res.body.budget.category).toBe("leisure");
  });

  test("Lấy danh sách ngân sách thất bại nếu tháng không hợp lệ", async () => {
    const token = getToken();

    const res = await request(app)
      .get("/api/budgets?month=13&year=2026")
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toBe("Invalid month or year");
  });

  test("Lấy danh sách ngân sách thành công", async () => {
    const token = getToken();

    budgetModel.getBudgetsByMonth.mockResolvedValue([
      {
        category: "food",
        limitAmount: 100,
        spent: 30,
        remaining: 70,
        percentageUsed: 30,
        status: "safe",
      },
    ]);

    const res = await request(app)
      .get("/api/budgets?month=5&year=2026")
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.budgets)).toBe(true);
    expect(res.body.budgets[0].status).toBe("safe");
  });
});
