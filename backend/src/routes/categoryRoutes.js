const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const categoryController = require("../controllers/categoryController");

router.get("/", authMiddleware, categoryController.getMyCategories);
router.post("/", authMiddleware, categoryController.createCategory);

module.exports = router;
