const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const statisticsController = require("../controllers/statisticsController");

router.get("/trend", authMiddleware, statisticsController.getSpendingTrend);

router.get("/", authMiddleware, statisticsController.getMonthlyStatistics);

router.get("/export", authMiddleware, statisticsController.exportMonthlyReport);

module.exports = router;
