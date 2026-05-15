const db = require("../config/db");

const defaultCategories = ["food", "travel", "leisure", "work"];

const normalizeCategoryName = (name) => name.trim().toLowerCase();

const getCategoriesByUserId = async (userId) => {
  const [rows] = await db.execute(
    `
      SELECT id, user_id, name, created_at, updated_at
      FROM categories
      WHERE user_id = ?
      ORDER BY id ASC
    `,
    [userId],
  );

  return rows;
};

const findCategoryByIdAndUserId = async (categoryId, userId) => {
  const [rows] = await db.execute(
    `
      SELECT id, user_id, name, created_at, updated_at
      FROM categories
      WHERE id = ? AND user_id = ?
      LIMIT 1
    `,
    [categoryId, userId],
  );

  return rows[0];
};

const findCategoryByNameAndUserId = async (name, userId) => {
  const normalizedName = normalizeCategoryName(name);

  const [rows] = await db.execute(
    `
      SELECT id, user_id, name, created_at, updated_at
      FROM categories
      WHERE name = ? AND user_id = ?
      LIMIT 1
    `,
    [normalizedName, userId],
  );

  return rows[0];
};

const createCategory = async (userId, name) => {
  const normalizedName = normalizeCategoryName(name);

  const [result] = await db.execute(
    `
      INSERT INTO categories (user_id, name)
      VALUES (?, ?)
    `,
    [userId, normalizedName],
  );

  return findCategoryByIdAndUserId(result.insertId, userId);
};

const createDefaultCategoriesForUser = async (userId) => {
  const values = defaultCategories.map((name) => [userId, name]);

  await db.query(
    `
      INSERT IGNORE INTO categories (user_id, name)
      VALUES ?
    `,
    [values],
  );
};

module.exports = {
  defaultCategories,
  normalizeCategoryName,
  getCategoriesByUserId,
  findCategoryByIdAndUserId,
  findCategoryByNameAndUserId,
  createCategory,
  createDefaultCategoriesForUser,
};
