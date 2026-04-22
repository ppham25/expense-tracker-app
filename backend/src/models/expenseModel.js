const db = require("../config/db");

const createExpense = async (userId, title, amount, category, expenseDate) => {
  const [result] = await db.execute(
    `
      INSERT INTO expenses (user_id, title, amount, category, expense_date)
      VALUES (?, ?, ?, ?, ?)
    `,
    [userId, title, amount, category, expenseDate],
  );

  const [rows] = await db.execute(
    `
      SELECT id, user_id, title, amount, category, expense_date, created_at, updated_at
      FROM expenses
      WHERE id = ?
      LIMIT 1
    `,
    [result.insertId],
  );

  return rows[0];
};

const getExpensesByUserId = async (userId) => {
  const [rows] = await db.execute(
    `
      SELECT id, user_id, title, amount, category, expense_date, created_at, updated_at
      FROM expenses
      WHERE user_id = ?
      ORDER BY expense_date DESC, id DESC
    `,
    [userId],
  );

  return rows;
};

const deleteExpenseByIdAndUserId = async (expenseId, userId) => {
  const [result] = await db.execute(
    `
      DELETE FROM expenses
      WHERE id = ? AND user_id = ?
    `,
    [expenseId, userId],
  );

  return result.affectedRows;
};

const updateExpenseByIdAndUser = async (
  expenseId,
  userId,
  title,
  amount,
  category,
  expenseDate,
) => {
  const [result] = await db.execute(
    `
    UPDATE expenses
SET title = ?, amount = ?, category = ?, expense_date = ?
WHERE id = ? AND user_id = ?
    `,
    [title, amount, category, expenseDate, expenseId, userId],
  );
  if (result.affectedRows === 0) return null;
  const [rows] = await db.execute(
    `
      SELECT id, user_id, title, amount, category, expense_date, created_at, updated_at
      FROM expenses
      WHERE id = ?
      LIMIT 1
    `,
    [expenseId],
  );
  return rows[0];
};

module.exports = {
  createExpense,
  getExpensesByUserId,
  deleteExpenseByIdAndUserId,
  updateExpenseByIdAndUser,
};
