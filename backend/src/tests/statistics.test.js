const request = require("supertest");
const jwt = require("jsonwebtoken");

jest.mock("../models/statisticsModel", () => ({
  getStatisticsByUserAndMonth: jest.fn(),
}));

const app = require("../app");
const statisticsModel = require("../models/statisticsModel");

beforeAll(() => {
  process.env.JWT_SECRET = "test_secret";
});

beforeEach(() => {
  jest.clearAllMocks();
});

const getToken = () => jwt.sign({ userId: 1 }, process.env.JWT_SECRET);

describe("Statistics API", () => {
  test("Không cho lấy thống kê nếu thiếu token", async () => {
    const res = await request(app).get("/api/statistics?month=5&year=2026");

    expect(res.statusCode).toBe(401);
  });

  test("Không cho lấy thống kê nếu tháng không hợp lệ", async () => {
    const token = getToken();

    const res = await request(app)
      .get("/api/statistics?month=13&year=2026")
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toBe("Month must be a number between 1 and 12");
  });

  test("Không cho lấy thống kê nếu năm không hợp lệ", async () => {
    const token = getToken();

    const res = await request(app)
      .get("/api/statistics?month=5&year=1000")
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toBe("Year must be a valid number");
  });

  test("Lấy thống kê tháng thành công", async () => {
    const token = getToken();

    statisticsModel.getStatisticsByUserAndMonth.mockResolvedValue({
      month: 5,
      year: 2026,
      monthlySummary: {
        totalSpent: 500000,
        expenseCount: 3,
      },
      dailySpending: [],
      categoryBreakdown: [
        {
          categoryId: 1,
          category: "food",
          amount: 300000,
          percentage: 60,
        },
      ],
      topExpenses: [
        {
          id: 1,
          title: "Hội An",
          amount: 500000,
          category: "travel",
        },
      ],
    });

    const res = await request(app)
      .get("/api/statistics?month=5&year=2026")
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.month).toBe(5);
    expect(res.body.year).toBe(2026);
    expect(res.body.monthlySummary.totalSpent).toBe(500000);
    expect(Array.isArray(res.body.categoryBreakdown)).toBe(true);
  });
});
