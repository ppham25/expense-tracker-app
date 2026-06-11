const request = require("supertest");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

jest.mock("../models/userModel", () => ({
  findByEmail: jest.fn(),
  findById: jest.fn(),
  findAuthById: jest.fn(),
  createUser: jest.fn(),
  updatePassword: jest.fn(),
}));

jest.mock("../models/categoryModel", () => ({
  createDefaultCategoriesForUser: jest.fn(),
}));

const app = require("../app");
const userModel = require("../models/userModel");
const categoryModel = require("../models/categoryModel");

beforeAll(() => {
  process.env.JWT_SECRET = "test_secret";
});

beforeEach(() => {
  jest.clearAllMocks();
});

describe("Auth API", () => {
  test("Đăng ký thất bại khi thiếu dữ liệu", async () => {
    const res = await request(app).post("/api/auth/register").send({
      email: "user4@gmail.com",
      password: "123456",
    });

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toBe("Name, email and password are required");
  });

  test("Đăng ký thất bại khi email đã tồn tại", async () => {
    userModel.findByEmail.mockResolvedValue({
      id: 1,
      name: "user1",
      email: "user1@gmail.com",
    });

    const res = await request(app).post("/api/auth/register").send({
      name: "user1",
      email: "user1@gmail.com",
      password: "123456",
    });

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toBe("Email already exists");
  });

  test("Đăng ký thành công khi dữ liệu hợp lệ", async () => {
    userModel.findByEmail.mockResolvedValue(null);
    userModel.createUser.mockResolvedValue(4);
    categoryModel.createDefaultCategoriesForUser.mockResolvedValue();

    const res = await request(app).post("/api/auth/register").send({
      name: "user4",
      email: "user4@gmail.com",
      password: "123456",
    });

    expect(res.statusCode).toBe(201);
    expect(res.body.message).toBe("Register successful");
    expect(res.body.user.id).toBe(4);
    expect(res.body.user.email).toBe("user4@gmail.com");
    expect(categoryModel.createDefaultCategoriesForUser).toHaveBeenCalledWith(
      4,
    );
  });

  test("Đăng nhập thất bại khi sai mật khẩu", async () => {
    const passwordHash = await bcrypt.hash("123456", 10);

    userModel.findByEmail.mockResolvedValue({
      id: 1,
      name: "user1",
      email: "user1@gmail.com",
      password_hash: passwordHash,
    });

    const res = await request(app).post("/api/auth/login").send({
      email: "user1@gmail.com",
      password: "111111",
    });

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toBe("Invalid email or password");
    expect(res.body.token).toBeUndefined();
  });

  test("Đăng nhập thành công khi email và mật khẩu đúng", async () => {
    const passwordHash = await bcrypt.hash("123456", 10);

    userModel.findByEmail.mockResolvedValue({
      id: 1,
      name: "user1",
      email: "user1@gmail.com",
      password_hash: passwordHash,
    });

    const res = await request(app).post("/api/auth/login").send({
      email: "user1@gmail.com",
      password: "123456",
    });

    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe("Login successful");
    expect(res.body.token).toBeDefined();
    expect(res.body.user.email).toBe("user1@gmail.com");
  });

  test("Lấy thông tin cá nhân thất bại khi không gửi token", async () => {
    const res = await request(app).get("/api/auth/me");

    expect(res.statusCode).toBe(401);
    expect(res.body.message).toBe("Unauthorized");
  });

  test("Lấy thông tin cá nhân thành công khi token hợp lệ", async () => {
    const token = jwt.sign({ userId: 1 }, process.env.JWT_SECRET);

    userModel.findById.mockResolvedValue({
      id: 1,
      name: "user1",
      email: "user1@gmail.com",
    });

    const res = await request(app)
      .get("/api/auth/me")
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.user.email).toBe("user1@gmail.com");
  });
});
