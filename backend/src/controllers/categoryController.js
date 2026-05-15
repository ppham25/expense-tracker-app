const categoryModel = require("../models/categoryModel");

const getMyCategories = async (req, res) => {
  try {
    const userId = req.user.userId;
    const categories = await categoryModel.getCategoriesByUserId(userId);

    return res.status(200).json({ categories });
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const createCategory = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { name } = req.body;

    if (!name || !name.trim()) {
      return res.status(400).json({
        message: "Category name is required",
      });
    }

    if (name.trim().length > 100) {
      return res.status(400).json({
        message: "Category name must be less than 100 characters",
      });
    }

    const category = await categoryModel.createCategory(userId, name);

    return res.status(201).json({
      message: "Category created successfully",
      category,
    });
  } catch (error) {
    if (error.code === "ER_DUP_ENTRY") {
      return res.status(400).json({
        message: "Category already exists",
      });
    }

    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

module.exports = {
  getMyCategories,
  createCategory,
};
