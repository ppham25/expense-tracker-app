const statisticsModel = require("../models/statisticsModel");

const validateMonthAndYear = (month, year, res) => {
  if (Number.isNaN(month) || month < 1 || month > 12) {
    res.status(400).json({
      message: "Month must be a number between 1 and 12",
    });
    return false;
  }

  if (Number.isNaN(year) || year < 2000 || year > 3000) {
    res.status(400).json({
      message: "Year must be a valid number",
    });
    return false;
  }

  return true;
};

const escapeCsvValue = (value) => {
  if (value === null || value === undefined) {
    return "";
  }

  const stringValue = String(value);
  const escapedValue = stringValue.replace(/"/g, '""');

  return `"${escapedValue}"`;
};

const getMonthlyStatistics = async (req, res) => {
  try {
    const userId = req.user.userId;
    const month = Number(req.query.month);
    const year = Number(req.query.year);

    if (!validateMonthAndYear(month, year, res)) {
      return;
    }

    const statistics = await statisticsModel.getStatisticsByUserAndMonth(
      userId,
      month,
      year,
    );

    return res.status(200).json(statistics);
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const exportMonthlyReport = async (req, res) => {
  try {
    const userId = req.user.userId;
    const month = Number(req.query.month);
    const year = Number(req.query.year);

    if (!validateMonthAndYear(month, year, res)) {
      return;
    }

    const statistics = await statisticsModel.getStatisticsByUserAndMonth(
      userId,
      month,
      year,
    );

    const rows = [];

    rows.push(["EXPENSE REPORT"]);
    rows.push(["Month", month]);
    rows.push(["Year", year]);
    rows.push([]);

    rows.push(["SUMMARY"]);
    rows.push(["Total spent", statistics.monthlySummary.totalSpent]);
    rows.push(["Expense count", statistics.monthlySummary.expenseCount]);
    rows.push([]);

    rows.push(["CATEGORY BREAKDOWN"]);
    rows.push(["Category", "Amount", "Percentage"]);
    statistics.categoryBreakdown.forEach((item) => {
      rows.push([item.category, item.amount, `${item.percentage}%`]);
    });
    rows.push([]);

    rows.push(["TOP EXPENSES"]);
    rows.push(["Title", "Amount", "Category", "Expense date"]);
    statistics.topExpenses.forEach((item) => {
      rows.push([item.title, item.amount, item.category, item.expense_date]);
    });
    rows.push([]);

    rows.push(["DAILY SPENDING"]);
    rows.push(["Day", "Amount"]);
    statistics.dailySpending.forEach((item) => {
      rows.push([item.day, item.amount]);
    });

    const csvContent = rows
      .map((row) => row.map(escapeCsvValue).join(","))
      .join("\n");

    const fileName = `expense_report_${month}_${year}.csv`;

    res.setHeader("Content-Type", "text/csv; charset=utf-8");
    res.setHeader("Content-Disposition", `attachment; filename="${fileName}"`);

    return res.status(200).send("\uFEFF" + csvContent);
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const getSpendingTrend = async (req, res) => {
  try {
    const userId = req.user.userId;
    const month = Number(req.query.month);
    const year = Number(req.query.year);
    const numberOfMonths = Number(req.query.months || 6);

    if (Number.isNaN(month) || month < 1 || month > 12) {
      return res.status(400).json({
        message: "Month must be a number between 1 and 12",
      });
    }

    if (Number.isNaN(year) || year < 2000 || year > 3000) {
      return res.status(400).json({
        message: "Year must be a valid number",
      });
    }

    if (
      Number.isNaN(numberOfMonths) ||
      numberOfMonths < 2 ||
      numberOfMonths > 12
    ) {
      return res.status(400).json({
        message: "Months must be a number between 2 and 12",
      });
    }

    const trend = await statisticsModel.getSpendingTrendByUser(
      userId,
      month,
      year,
      numberOfMonths,
    );

    return res.status(200).json(trend);
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};
module.exports = {
  getMonthlyStatistics,
  exportMonthlyReport,
  getSpendingTrend,
};
