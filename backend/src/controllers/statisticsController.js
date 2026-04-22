const statisticsModel = require("../models/statisticsModel");

const getMonthlyStatistics = async (req, res) => {
  try {
    const userId = req.user.userId;
    const month = Number(req.query.month);
    const year = Number(req.query.year);

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

module.exports = {
  getMonthlyStatistics,
};
