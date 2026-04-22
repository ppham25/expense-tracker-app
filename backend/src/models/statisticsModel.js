const db = require("../config/db");

const getStatisticsByUserAndMonth = async (userId, month, year) => {
  const monthString = String(month).padStart(2, "0");
  const startDate = `${year}-${monthString}-01`;
  const endDate = new Date(year, month, 0).toISOString().split("T")[0];
  const daysInMonth = new Date(year, month, 0).getDate();

  const [summaryRows] = await db.execute(
    `
      SELECT
        COALESCE(SUM(amount), 0) AS total_spent,
        COUNT(*) AS expense_count
      FROM expenses
      WHERE user_id = ?
        AND expense_date BETWEEN ? AND ?
    `,
    [userId, startDate, endDate],
  );

  const totalSpent = Number(summaryRows[0].total_spent || 0);
  const expenseCount = Number(summaryRows[0].expense_count || 0);

  const [dailyRows] = await db.execute(
    `
      SELECT
        DAY(expense_date) AS day,
        SUM(amount) AS amount
      FROM expenses
      WHERE user_id = ?
        AND expense_date BETWEEN ? AND ?
      GROUP BY DAY(expense_date)
      ORDER BY DAY(expense_date)
    `,
    [userId, startDate, endDate],
  );

  const dailySpendingMap = new Map();
  for (const row of dailyRows) {
    dailySpendingMap.set(Number(row.day), Number(row.amount));
  }

  const dailySpending = [];
  for (let day = 1; day <= daysInMonth; day++) {
    dailySpending.push({
      day,
      amount: dailySpendingMap.get(day) || 0,
    });
  }

  const [categoryRows] = await db.execute(
    `
      SELECT
        category,
        SUM(amount) AS amount
      FROM expenses
      WHERE user_id = ?
        AND expense_date BETWEEN ? AND ?
      GROUP BY category
      ORDER BY amount DESC
    `,
    [userId, startDate, endDate],
  );

  const categoryBreakdown = categoryRows.map((row) => {
    const amount = Number(row.amount || 0);
    const percentage =
      totalSpent === 0 ? 0 : Number(((amount / totalSpent) * 100).toFixed(1));

    return {
      category: row.category,
      amount,
      percentage,
    };
  });

  const [topExpenseRows] = await db.execute(
    `
      SELECT
        id,
        title,
        amount,
        category,
        expense_date
      FROM expenses
      WHERE user_id = ?
        AND expense_date BETWEEN ? AND ?
      ORDER BY amount DESC, expense_date DESC, id DESC
      LIMIT 3
    `,
    [userId, startDate, endDate],
  );

  const topExpenses = topExpenseRows.map((row) => ({
    id: row.id,
    title: row.title,
    amount: Number(row.amount),
    category: row.category,
    expense_date: row.expense_date,
  }));

  return {
    month,
    year,
    monthlySummary: {
      totalSpent,
      expenseCount,
    },
    dailySpending,
    categoryBreakdown,
    topExpenses,
  };
};

module.exports = {
  getStatisticsByUserAndMonth,
};
