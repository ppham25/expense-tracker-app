const request = require("supertest");
const jwt = require("jsonwebtoken");

jest.mock("../models/expenseModel", () => ({
  createExpense: jest.fn(),
  getExpensesByUserId: jest.fn(),
  deleteExpenseByIdAndUserId: jest.fn(),
  updateExpenseByIdAndUser: jest.fn(),
}));

jest.mock("../models/categoryModel", () => ({
  findCategoryByIdAndUserId: jest.fn(),
  findCategoryByNameAndUserId: jest.fn(),
}));

const app = require("../app");
const expenseModel = require("../models/expenseModel");
const categoryModel = require("../models/categoryModel");

beforeAll(() => {
  process.env.JWT_SECRET = "test_secret";
});

beforeEach(() => {
  jest.clearAllMocks();
});

const getToken = () => jwt.sign({ userId: 1 }, process.env.JWT_SECRET);

describe("Expense API", () => {
  test("Không cho thêm khoản chi nếu thiếu token", async () => {
    const res = await request(app).post("/api/expenses").send({
      title: "Hội An",
      amount: 500,
      categoryId: 2,
      expense_date: "2026-04-22",
    });

    expect(res.statusCode).toBe(401);
  });

  test("Không cho thêm khoản chi nếu số tiền bằng 0", async () => {
    const token = getToken();

    const res = await request(app)
      .post("/api/expenses")
      .set("Authorization", `Bearer ${token}`)
      .send({
        title: "Hội An",
        amount: 0,
        categoryId: 2,
        expense_date: "2026-04-22",
      });

    expect(res.statusCode).toBe(400);

    // Code hiện tại dùng điều kiện !amount nên amount = 0 được xử lý như thiếu dữ liệu.
    expect(res.body.message).toBe(
      "Title, amount, category and expense_date are required",
    );
  });

  test("Không cho thêm khoản chi nếu danh mục không hợp lệ", async () => {
    const token = getToken();

    categoryModel.findCategoryByIdAndUserId.mockResolvedValue(null);

    const res = await request(app)
      .post("/api/expenses")
      .set("Authorization", `Bearer ${token}`)
      .send({
        title: "Hội An",
        amount: 500,
        categoryId: 999,
        expense_date: "2026-04-22",
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toBe("Invalid category");
  });

  test("Thêm khoản chi thành công khi dữ liệu hợp lệ", async () => {
    const token = getToken();

    categoryModel.findCategoryByIdAndUserId.mockResolvedValue({
      id: 2,
      user_id: 1,
      name: "travel",
    });

    expenseModel.createExpense.mockResolvedValue({
      id: 10,
      user_id: 1,
      title: "Hội An",
      amount: 500,
      categoryId: 2,
      category: "travel",
      expense_date: "2026-04-22",
    });

    const res = await request(app)
      .post("/api/expenses")
      .set("Authorization", `Bearer ${token}`)
      .send({
        title: "Hội An",
        amount: 500,
        categoryId: 2,
        expense_date: "2026-04-22",
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.message).toBe("Expense created successfully");
    expect(res.body.expense.title).toBe("Hội An");
    expect(res.body.expense.amount).toBe(500);
  });

  test("Lấy danh sách khoản chi thành công", async () => {
    const token = getToken();

    expenseModel.getExpensesByUserId.mockResolvedValue([
      {
        id: 1,
        title: "Ăn sáng",
        amount: 50000,
        category: "food",
      },
    ]);

    const res = await request(app)
      .get("/api/expenses")
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.expenses)).toBe(true);
    expect(res.body.expenses[0].title).toBe("Ăn sáng");
  });
});
