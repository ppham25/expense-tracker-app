const budgetModel = require("../models/budgetModel");
const categoryModel = require("../models/categoryModel");

const getCategoryFromRequest = async (req, userId) => {
  const rawCategoryId = req.body.categoryId ?? req.body.category_id;

  if (rawCategoryId !== undefined && rawCategoryId !== null) {
    const categoryId = Number(rawCategoryId);

    if (Number.isNaN(categoryId)) return null;

    return categoryModel.findCategoryByIdAndUserId(categoryId, userId);
  }

  if (req.body.category) {
    return categoryModel.findCategoryByNameAndUserId(req.body.category, userId);
  }

  return null;
};

const createBudget = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { limitAmount, month, year } = req.body;

    const category = await getCategoryFromRequest(req, userId);

    if (!category) {
      return res.status(400).json({ message: "Invalid category" });
    }

    const parsedLimitAmount = Number(limitAmount);
    const parsedMonth = Number(month);
    const parsedYear = Number(year);

    if (Number.isNaN(parsedLimitAmount) || parsedLimitAmount <= 0) {
      return res.status(400).json({
        message: "Limit amount must be a number greater than 0",
      });
    }

    if (
      Number.isNaN(parsedMonth) ||
      parsedMonth < 1 ||
      parsedMonth > 12 ||
      Number.isNaN(parsedYear)
    ) {
      return res.status(400).json({ message: "Invalid month or year" });
    }

    const budget = await budgetModel.createBudget(
      userId,
      category.id,
      parsedLimitAmount,
      parsedMonth,
      parsedYear,
    );

    return res.status(201).json({
      message: "Budget created",
      budget,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      message: "Failed to create budget",
      error: error.message,
    });
  }
};

const getBudgets = async (req, res) => {
  try {
    const userId = req.user.userId;
    const month = Number(req.query.month);
    const year = Number(req.query.year);

    if (Number.isNaN(month) || month < 1 || month > 12 || Number.isNaN(year)) {
      return res.status(400).json({ message: "Invalid month or year" });
    }

    const budgets = await budgetModel.getBudgetsByMonth(userId, month, year);

    return res.status(200).json({
      budgets,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      message: "Failed to load budgets",
      error: error.message,
    });
  }
};

const updateBudget = async (req, res) => {
  try {
    const userId = req.user.userId;
    const budgetId = Number(req.params.id);
    const { limitAmount } = req.body;

    if (Number.isNaN(budgetId)) {
      return res.status(400).json({ message: "Invalid budget id" });
    }

    const parsedLimitAmount = Number(limitAmount);

    if (Number.isNaN(parsedLimitAmount) || parsedLimitAmount <= 0) {
      return res.status(400).json({
        message: "Limit amount must be a number greater than 0",
      });
    }

    const budget = await budgetModel.updateBudget(
      budgetId,
      userId,
      parsedLimitAmount,
    );

    if (!budget) {
      return res.status(404).json({ message: "Budget not found" });
    }

    return res.status(200).json({
      message: "Budget updated",
      budget,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      message: "Failed to update budget",
      error: error.message,
    });
  }
};

const deleteBudget = async (req, res) => {
  try {
    const userId = req.user.userId;
    const budgetId = Number(req.params.id);

    if (Number.isNaN(budgetId)) {
      return res.status(400).json({ message: "Invalid budget id" });
    }

    await budgetModel.deleteBudget(budgetId, userId);

    return res.status(200).json({
      message: "Budget deleted",
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      message: "Failed to delete budget",
      error: error.message,
    });
  }
};

module.exports = {
  createBudget,
  getBudgets,
  updateBudget,
  deleteBudget,
};
