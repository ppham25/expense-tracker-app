const express = require("express");

const router = express.Router();

const authenticateToken = require("../middleware/authMiddleware");

const budgetController = require("../controllers/budgetController");

router.use(authenticateToken);

router.post("/", budgetController.createBudget);

router.get("/", budgetController.getBudgets);

router.put("/:id", budgetController.updateBudget);

router.delete("/:id", budgetController.deleteBudget);

module.exports = router;
