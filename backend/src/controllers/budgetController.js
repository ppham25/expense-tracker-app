const budgetModel = require("../models/budgetModel");

const createBudget = async (req, res) => {
  try {
    const userId = req.user.id;

    const { category, limitAmount, month, year } = req.body;

    const budget = await budgetModel.createBudget(
      userId,
      category,
      limitAmount,
      month,
      year,
    );

    res.status(201).json({
      message: "Budget created",
      budget,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Failed to create budget",
    });
  }
};

const getBudgets = async (req, res) => {
  try {
    const userId = req.user.id;

    const month = Number(req.query.month);

    const year = Number(req.query.year);

    const budgets = await budgetModel.getBudgetsByMonth(userId, month, year);

    res.status(200).json({
      budgets,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Failed to load budgets",
    });
  }
};

const updateBudget = async (req, res) => {
  try {
    const userId = req.user.id;

    const budgetId = req.params.id;

    const { limitAmount } = req.body;

    const budget = await budgetModel.updateBudget(
      budgetId,
      userId,
      limitAmount,
    );

    res.status(200).json({
      message: "Budget updated",
      budget,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Failed to update budget",
    });
  }
};

const deleteBudget = async (req, res) => {
  try {
    const userId = req.user.id;

    const budgetId = req.params.id;

    await budgetModel.deleteBudget(budgetId, userId);

    res.status(200).json({
      message: "Budget deleted",
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Failed to delete budget",
    });
  }
};

module.exports = {
  createBudget,
  getBudgets,
  updateBudget,
  deleteBudget,
};
