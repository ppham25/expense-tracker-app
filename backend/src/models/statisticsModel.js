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
        e.category_id AS categoryId,
        c.name AS category,
        SUM(e.amount) AS amount
      FROM expenses e
      JOIN categories c ON e.category_id = c.id
      WHERE e.user_id = ?
        AND e.expense_date BETWEEN ? AND ?
      GROUP BY e.category_id, c.name
      ORDER BY amount DESC
    `,
    [userId, startDate, endDate],
  );

  const categoryBreakdown = categoryRows.map((row) => {
    const amount = Number(row.amount || 0);
    const percentage =
      totalSpent === 0 ? 0 : Number(((amount / totalSpent) * 100).toFixed(1));

    return {
      categoryId: row.categoryId,
      category: row.category,
      amount,
      percentage,
    };
  });

  const [topExpenseRows] = await db.execute(
    `
      SELECT
        e.id,
        e.title,
        e.amount,
        e.category_id AS categoryId,
        c.name AS category,
        e.expense_date
      FROM expenses e
      JOIN categories c ON e.category_id = c.id
      WHERE e.user_id = ?
        AND e.expense_date BETWEEN ? AND ?
      ORDER BY e.amount DESC, e.expense_date DESC, e.id DESC
      LIMIT 3
    `,
    [userId, startDate, endDate],
  );

  const topExpenses = topExpenseRows.map((row) => ({
    id: row.id,
    title: row.title,
    amount: Number(row.amount),
    categoryId: row.categoryId,
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

const getSpendingTrendByUser = async (
  userId,
  month,
  year,
  numberOfMonths = 6,
) => {
  const selectedDate = new Date(year, month - 1, 1);

  const trendItems = [];

  for (let i = numberOfMonths - 1; i >= 0; i--) {
    const currentDate = new Date(
      selectedDate.getFullYear(),
      selectedDate.getMonth() - i,
      1,
    );

    const currentMonth = currentDate.getMonth() + 1;
    const currentYear = currentDate.getFullYear();

    const monthString = String(currentMonth).padStart(2, "0");
    const startDate = `${currentYear}-${monthString}-01`;
    const endDate = new Date(currentYear, currentMonth, 0)
      .toISOString()
      .split("T")[0];

    const [rows] = await db.execute(
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

    trendItems.push({
      month: currentMonth,
      year: currentYear,
      totalSpent: Number(rows[0].total_spent || 0),
      expenseCount: Number(rows[0].expense_count || 0),
    });
  }

  const currentMonthData = trendItems[trendItems.length - 1];
  const previousMonthData = trendItems[trendItems.length - 2];

  let changeAmount = 0;
  let changePercentage = 0;
  let trendStatus = "stable";
  let message = "Chi tiêu không thay đổi nhiều so với tháng trước.";

  if (previousMonthData) {
    changeAmount = currentMonthData.totalSpent - previousMonthData.totalSpent;

    if (previousMonthData.totalSpent === 0 && currentMonthData.totalSpent > 0) {
      changePercentage = 100;
      trendStatus = "increase";
      message = "Tháng này phát sinh chi tiêu mới so với tháng trước.";
    } else if (
      previousMonthData.totalSpent > 0 &&
      currentMonthData.totalSpent === 0
    ) {
      changePercentage = -100;
      trendStatus = "decrease";
      message = "Chi tiêu tháng này giảm hoàn toàn so với tháng trước.";
    } else if (previousMonthData.totalSpent > 0) {
      changePercentage = Number(
        ((changeAmount / previousMonthData.totalSpent) * 100).toFixed(1),
      );

      if (changePercentage > 0) {
        trendStatus = "increase";
        message = `Chi tiêu tháng này tăng ${changePercentage}% so với tháng trước.`;
      } else if (changePercentage < 0) {
        trendStatus = "decrease";
        message = `Chi tiêu tháng này giảm ${Math.abs(
          changePercentage,
        )}% so với tháng trước.`;
      }
    }
  }

  return {
    selectedMonth: month,
    selectedYear: year,
    previousMonth: previousMonthData
      ? {
          month: previousMonthData.month,
          year: previousMonthData.year,
          totalSpent: previousMonthData.totalSpent,
        }
      : null,
    currentMonth: {
      month: currentMonthData.month,
      year: currentMonthData.year,
      totalSpent: currentMonthData.totalSpent,
    },
    changeAmount,
    changePercentage,
    trendStatus,
    message,
    monthlyTrend: trendItems,
  };
};
module.exports = {
  getStatisticsByUserAndMonth,
  getSpendingTrendByUser,
};
