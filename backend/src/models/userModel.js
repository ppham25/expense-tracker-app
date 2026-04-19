const db = require("../config/db");

const findByEmail = async (email) => {
  const [rows] = await db.execute(
    "SELECT * FROM users WHERE email = ? LIMIT 1",
    [email],
  );
  return rows[0];
};

const findById = async (id) => {
  const [rows] = await db.execute(
    "SELECT id, name, email, created_at, updated_at FROM users WHERE id = ? LIMIT 1",
    [id],
  );
  return rows[0];
};

const createUser = async (name, email, passwordHash) => {
  const [result] = await db.execute(
    "INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)",
    [name, email, passwordHash],
  );
  return result.insertId;
};

module.exports = {
  findByEmail,
  createUser,
  findById,
};
