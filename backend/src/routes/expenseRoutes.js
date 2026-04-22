const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const expenseController = require("../controllers/expenseController");

router.get("/", authMiddleware, expenseController.getMyExpenses);
router.post("/", authMiddleware, expenseController.createExpense);
router.put("/:id", authMiddleware, expenseController.updateExpense);
router.delete("/:id", authMiddleware, expenseController.deleteExpense);

module.exports = router;
