const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const budgetMessageController = require("../controllers/budgetMessageController");

router.get("/random", authMiddleware, budgetMessageController.getRandomMessage);

module.exports = router;
