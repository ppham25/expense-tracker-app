const db = require("../config/db");

const selectExpenseById = async (expenseId) => {
  const [rows] = await db.execute(
    `
      SELECT
        e.id,
        e.user_id,
        e.title,
        e.amount,
        e.category_id AS categoryId,
        c.name AS category,
        e.expense_date,
        e.created_at,
        e.updated_at
      FROM expenses e
      JOIN categories c ON e.category_id = c.id
      WHERE e.id = ?
      LIMIT 1
    `,
    [expenseId],
  );

  return rows[0];
};

const createExpense = async (
  userId,
  title,
  amount,
  categoryId,
  expenseDate,
) => {
  const [result] = await db.execute(
    `
      INSERT INTO expenses (user_id, title, amount, category_id, expense_date)
      VALUES (?, ?, ?, ?, ?)
    `,
    [userId, title, amount, categoryId, expenseDate],
  );

  return selectExpenseById(result.insertId);
};

const getExpensesByUserId = async (userId) => {
  const [rows] = await db.execute(
    `
      SELECT
        e.id,
        e.user_id,
        e.title,
        e.amount,
        e.category_id AS categoryId,
        c.name AS category,
        e.expense_date,
        e.created_at,
        e.updated_at
      FROM expenses e
      JOIN categories c ON e.category_id = c.id
      WHERE e.user_id = ?
      ORDER BY e.expense_date DESC, e.id DESC
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
  categoryId,
  expenseDate,
) => {
  const [result] = await db.execute(
    `
      UPDATE expenses
      SET title = ?, amount = ?, category_id = ?, expense_date = ?
      WHERE id = ? AND user_id = ?
    `,
    [title, amount, categoryId, expenseDate, expenseId, userId],
  );

  if (result.affectedRows === 0) return null;

  return selectExpenseById(expenseId);
};

module.exports = {
  createExpense,
  getExpensesByUserId,
  deleteExpenseByIdAndUserId,
  updateExpenseByIdAndUser,
};
