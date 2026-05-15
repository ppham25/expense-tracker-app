const db = require("../config/db");
const budgetMessageModel = require("./budgetMessageModel");

const selectBudgetByUserCategoryMonth = async (
  userId,
  categoryId,
  month,
  year,
) => {
  const [rows] = await db.execute(
    `
      SELECT
        b.id,
        b.user_id,
        b.category_id AS categoryId,
        c.name AS category,
        b.limit_amount,
        b.month,
        b.year,
        b.created_at,
        b.updated_at
      FROM budgets b
      JOIN categories c ON b.category_id = c.id
      WHERE b.user_id = ?
        AND b.category_id = ?
        AND b.month = ?
        AND b.year = ?
      LIMIT 1
    `,
    [userId, categoryId, month, year],
  );

  return rows[0];
};

const createBudget = async (userId, categoryId, limitAmount, month, year) => {
  await db.execute(
    `
      INSERT INTO budgets (user_id, category_id, limit_amount, month, year)
      VALUES (?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        limit_amount = VALUES(limit_amount),
        updated_at = CURRENT_TIMESTAMP
    `,
    [userId, categoryId, limitAmount, month, year],
  );

  return selectBudgetByUserCategoryMonth(userId, categoryId, month, year);
};

const getBudgetsByMonth = async (userId, month, year) => {
  const [categoryRows] = await db.execute(
    `
      SELECT id, name
      FROM categories
      WHERE user_id = ?
      ORDER BY id ASC
    `,
    [userId],
  );

  const [expenseRows] = await db.execute(
    `
      SELECT
        category_id AS categoryId,
        COALESCE(SUM(amount), 0) AS spent
      FROM expenses
      WHERE user_id = ?
        AND MONTH(expense_date) = ?
        AND YEAR(expense_date) = ?
      GROUP BY category_id
    `,
    [userId, month, year],
  );

  const [budgetRows] = await db.execute(
    `
      SELECT
        id,
        category_id AS categoryId,
        limit_amount,
        month,
        year
      FROM budgets
      WHERE user_id = ?
        AND month = ?
        AND year = ?
    `,
    [userId, month, year],
  );

  const result = categoryRows.map((category) => {
    const expenseData = expenseRows.find(
      (item) => Number(item.categoryId) === Number(category.id),
    );

    const budgetData = budgetRows.find(
      (item) => Number(item.categoryId) === Number(category.id),
    );

    const spent = expenseData ? Number(expenseData.spent) : 0;

    const hasBudget = !!budgetData;

    const limitAmount = hasBudget ? Number(budgetData.limit_amount) : null;

    const remaining = hasBudget ? limitAmount - spent : null;

    const percentageUsed =
      hasBudget && limitAmount > 0
        ? Math.round((spent / limitAmount) * 100)
        : null;

    let status = "noBudget";

    if (hasBudget) {
      if (percentageUsed >= 100) {
        status = "over";
      } else if (percentageUsed >= 85) {
        status = "warning";
      } else if (percentageUsed >= 60) {
        status = "watch";
      } else {
        status = "safe";
      }
    }

    return {
      id: budgetData?.id ?? null,
      categoryId: category.id,
      category: category.name,
      hasBudget,
      limitAmount,
      spent,
      remaining,
      percentageUsed,
      status,
      month,
      year,
    };
  });

  const statuses = [...new Set(result.map((item) => item.status))];
  const messages = await budgetMessageModel.getMessagesByStatuses(statuses);

  const resultWithMessages = result.map((budget) => {
    const matchedMessages = messages.filter(
      (message) => message.status === budget.status,
    );

    let budgetMessage = null;

    if (matchedMessages.length > 0) {
      const randomIndex = Math.floor(Math.random() * matchedMessages.length);
      budgetMessage = matchedMessages[randomIndex].content;
    }

    return {
      ...budget,
      budgetMessage,
    };
  });

  return resultWithMessages;
};

const updateBudget = async (id, userId, limitAmount) => {
  await db.execute(
    `
      UPDATE budgets
      SET limit_amount = ?
      WHERE id = ?
        AND user_id = ?
    `,
    [limitAmount, id, userId],
  );

  const [rows] = await db.execute(
    `
      SELECT
        b.id,
        b.user_id,
        b.category_id AS categoryId,
        c.name AS category,
        b.limit_amount,
        b.month,
        b.year,
        b.created_at,
        b.updated_at
      FROM budgets b
      JOIN categories c ON b.category_id = c.id
      WHERE b.id = ? AND b.user_id = ?
      LIMIT 1
    `,
    [id, userId],
  );

  return rows[0];
};

const deleteBudget = async (id, userId) => {
  await db.execute(
    `
      DELETE FROM budgets
      WHERE id = ?
        AND user_id = ?
    `,
    [id, userId],
  );
};

module.exports = {
  createBudget,
  getBudgetsByMonth,
  updateBudget,
  deleteBudget,
};
