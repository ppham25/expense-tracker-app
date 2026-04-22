const expenseModel = require("../models/expenseModel");

const allowedCategories = ["food", "travel", "leisure", "work"];

const createExpense = async (req, res) => {
  try {
    const { title, amount, category, expense_date } = req.body;
    const userId = req.user.userId;

    if (!title || !amount || !category || !expense_date) {
      return res.status(400).json({
        message: "Title, amount, category and expense_date are required",
      });
    }

    if (!allowedCategories.includes(category)) {
      return res.status(400).json({
        message: "Invalid category",
      });
    }

    const parsedAmount = Number(amount);

    if (Number.isNaN(parsedAmount) || parsedAmount <= 0) {
      return res.status(400).json({
        message: "Amount must be a number greater than 0",
      });
    }

    const trimmedTitle = title.trim();

    if (!trimmedTitle) {
      return res.status(400).json({
        message: "Title cannot be empty",
      });
    }

    const newExpense = await expenseModel.createExpense(
      userId,
      trimmedTitle,
      parsedAmount,
      category,
      expense_date,
    );

    return res.status(201).json({
      message: "Expense created successfully",
      expense: newExpense,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const getMyExpenses = async (req, res) => {
  try {
    const userId = req.user.userId;

    const expenses = await expenseModel.getExpensesByUserId(userId);

    return res.status(200).json({
      expenses,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const deleteExpense = async (req, res) => {
  try {
    const expenseId = Number(req.params.id);
    const userId = req.user.userId;

    if (Number.isNaN(expenseId)) {
      return res.status(400).json({
        message: "Invalid expense id",
      });
    }

    const affectedRows = await expenseModel.deleteExpenseByIdAndUserId(
      expenseId,
      userId,
    );

    if (affectedRows === 0) {
      return res.status(404).json({
        message: "Expense not found",
      });
    }

    return res.status(200).json({
      message: "Expense deleted successfully",
    });
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const updateExpense = async (req, res) => {
  try {
    const expenseId = Number(req.params.id);
    const userId = req.user.userId;
    const { title, amount, category, expense_date } = req.body;

    if (Number.isNaN(expenseId)) {
      return res.status(400).json({
        message: "Invalid expense id",
      });
    }

    if (!title || !amount || !category || !expense_date) {
      return res.status(400).json({
        message: "Title, amount, category and expense_date are required",
      });
    }

    if (!allowedCategories.includes(category)) {
      return res.status(400).json({
        message: "Invalid category",
      });
    }

    const parsedAmount = Number(amount);

    if (Number.isNaN(parsedAmount) || parsedAmount <= 0) {
      return res.status(400).json({
        message: "Amount must be a number greater than 0",
      });
    }

    const trimmedTitle = title.trim();

    if (!trimmedTitle) {
      return res.status(400).json({
        message: "Title cannot be empty",
      });
    }

    const updatedExpense = await expenseModel.updateExpenseByIdAndUser(
      expenseId,
      userId,
      trimmedTitle,
      parsedAmount,
      category,
      expense_date,
    );

    if (!updatedExpense) {
      return res.status(404).json({
        message: "Expense not found",
      });
    }

    return res.status(200).json({
      message: "Expense updated successfully",
      expense: updatedExpense,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

module.exports = {
  createExpense,
  getMyExpenses,
  deleteExpense,
  updateExpense,
};
