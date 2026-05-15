const budgetMessageModel = require("../models/budgetMessageModel");

const getRandomMessage = async (req, res) => {
  try {
    const status = req.query.status;

    if (!budgetMessageModel.allowedStatuses.includes(status)) {
      return res.status(400).json({
        message: "Invalid budget status",
      });
    }

    const budgetMessage =
      await budgetMessageModel.getRandomMessageByStatus(status);

    if (!budgetMessage) {
      return res.status(404).json({
        message: "Budget message not found",
      });
    }

    return res.status(200).json({
      budgetMessage,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      message: "Failed to load budget message",
      error: error.message,
    });
  }
};

module.exports = {
  getRandomMessage,
};
