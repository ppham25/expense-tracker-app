const db = require("../config/db");

const createBudget = async (userId, category, limitAmount, month, year) => {
  const [result] = await db.execute(
    `
    INSERT INTO budgets
    (user_id, category, limit_amount, month, year)

    VALUES (?, ?, ?, ?, ?)
    `,
    [userId, category, limitAmount, month, year],
  );

  const [rows] = await db.execute(
    `
    SELECT *
    FROM budgets
    WHERE id = ?
    LIMIT 1
    `,
    [result.insertId],
  );

  return rows[0];
};

const getBudgetsByMonth = async (userId, month, year) => {
  const categories = ["food", "travel", "work", "leisure"];

  const [expenseRows] = await db.execute(
    `
    SELECT
      category,
      COALESCE(SUM(amount), 0) AS spent

    FROM expenses

    WHERE user_id = ?
      AND MONTH(expense_date) = ?
      AND YEAR(expense_date) = ?

    GROUP BY category
    `,
    [userId, month, year],
  );

  const [budgetRows] = await db.execute(
    `
    SELECT
      id,
      category,
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

  const result = categories.map((category) => {
    const expenseData = expenseRows.find((item) => item.category === category);

    const budgetData = budgetRows.find((item) => item.category === category);

    const spent = expenseData ? Number(expenseData.spent) : 0;

    const hasBudget = !!budgetData;

    const limitAmount = hasBudget ? Number(budgetData.limit_amount) : null;

    const remaining = hasBudget ? limitAmount - spent : null;

    const percentageUsed =
      hasBudget && limitAmount > 0
        ? Math.round((spent / limitAmount) * 100)
        : null;

    let status = "no_budget";

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

      category,

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

  return result;
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
    SELECT *
    FROM budgets
    WHERE id = ?
    LIMIT 1
    `,
    [id],
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
