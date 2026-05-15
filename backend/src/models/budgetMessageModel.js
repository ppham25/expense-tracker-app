const db = require("../config/db");

const allowedStatuses = ["noBudget", "safe", "watch", "warning", "over"];

const getRandomMessageByStatus = async (status) => {
  if (!allowedStatuses.includes(status)) {
    return null;
  }

  const [rows] = await db.execute(
    `
      SELECT
        id,
        status,
        message_type AS messageType,
        content
      FROM budget_messages
      WHERE status = ?
      ORDER BY RAND()
      LIMIT 1
    `,
    [status],
  );

  return rows[0] || null;
};

const getMessagesByStatuses = async (statuses) => {
  const validStatuses = statuses.filter((status) =>
    allowedStatuses.includes(status),
  );

  if (validStatuses.length === 0) {
    return [];
  }

  const placeholders = validStatuses.map(() => "?").join(", ");

  const [rows] = await db.execute(
    `
      SELECT
        id,
        status,
        message_type AS messageType,
        content
      FROM budget_messages
      WHERE status IN (${placeholders})
    `,
    validStatuses,
  );

  return rows;
};

module.exports = {
  allowedStatuses,
  getRandomMessageByStatus,
  getMessagesByStatuses,
};
