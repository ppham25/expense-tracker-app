DROP DATABASE IF EXISTS expense_manager;

CREATE DATABASE expense_manager;

USE expense_manager;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS expenses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  category VARCHAR(50) NOT NULL,
  expense_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_expenses_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS budgets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  category VARCHAR(50) NOT NULL,
  limit_amount DECIMAL(10,2) NOT NULL,
  month INT NOT NULL,
  year INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_budget_user
    FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);
USE expense_manager;

INSERT INTO expenses (user_id, title, amount, category, expense_date)
VALUES
  -- USER 1 : December 2025
  (1, 'Coffee', 50.00, 'food', '2025-12-05'),
  (1, 'Bus ticket', 20.00, 'travel', '2025-12-10'),
  (1, 'Book', 120.00, 'work', '2025-12-15'),

  -- USER 1 : January 2026
  (1, 'Lunch', 60.00, 'food', '2026-01-03'),
  (1, 'Taxi', 150.00, 'travel', '2026-01-12'),
  (1, 'Movie', 200.00, 'leisure', '2026-01-20'),

  -- USER 1 : February 2026 - vượt ngân sách food
  (1, 'Breakfast', 80.00, 'food', '2026-02-01'),
  (1, 'Lunch', 90.00, 'food', '2026-02-10'),
  (1, 'Dinner', 100.00, 'food', '2026-02-14'),
  (1, 'Grab', 60.00, 'travel', '2026-02-18'),

  -- USER 1 : March 2026 - gần hết ngân sách travel
  (1, 'Bus', 40.00, 'travel', '2026-03-05'),
  (1, 'Grab', 90.00, 'travel', '2026-03-10'),
  (1, 'Lunch', 70.00, 'food', '2026-03-12'),

  -- USER 1 : April 2026 - có chi tiêu leisure nhưng chưa có budget leisure
  (1, 'Game', 300.00, 'leisure', '2026-04-02'),
  (1, 'Milk tea', 45.00, 'food', '2026-04-10'),

  -- USER 1 : May 2026 - trước ngày 15/5/2026
  (1, 'Breakfast', 30.00, 'food', '2026-05-01'),
  (1, 'Bus', 20.00, 'travel', '2026-05-05'),

  -- USER 2 : December 2025
  (2, 'Pho', 40.00, 'food', '2025-12-08'),
  (2, 'Gas', 70.00, 'travel', '2025-12-18'),

  -- USER 2 : January 2026
  (2, 'Lunch', 55.00, 'food', '2026-01-07'),
  (2, 'Cinema', 120.00, 'leisure', '2026-01-15'),

  -- USER 2 : February 2026 - vượt ngân sách work
  (2, 'USB', 200.00, 'work', '2026-02-11'),
  (2, 'Coffee', 30.00, 'food', '2026-02-20'),

  -- USER 2 : March 2026 - gần hết ngân sách food
  (2, 'Lunch', 90.00, 'food', '2026-03-03'),
  (2, 'Dinner', 80.00, 'food', '2026-03-14'),

  -- USER 2 : April 2026 - có chi tiêu travel nhưng chưa có budget travel
  (2, 'Taxi', 150.00, 'travel', '2026-04-09'),

  -- USER 2 : May 2026 - trước ngày 15/5/2026
  (2, 'Breakfast', 35.00, 'food', '2026-05-10'),

  -- USER 3 : January 2026
  (3, 'Lunch', 60.00, 'food', '2026-01-05'),
  (3, 'Bus', 25.00, 'travel', '2026-01-15'),

  -- USER 3 : February 2026
  (3, 'Dinner', 70.00, 'food', '2026-02-14'),
  (3, 'Movie', 180.00, 'leisure', '2026-02-20'),

  -- USER 3 : March 2026 - vượt ngân sách leisure
  (3, 'Concert', 500.00, 'leisure', '2026-03-12'),

  -- USER 3 : April 2026 - gần hết ngân sách work
  (3, 'Notebook', 140.00, 'work', '2026-04-12'),
  (3, 'Pen', 60.00, 'work', '2026-04-14'),

  -- USER 3 : May 2026 - trước ngày 15/5/2026
  (3, 'Coffee', 40.00, 'food', '2026-05-12');
  USE expense_manager;

INSERT INTO budgets
(user_id, category, limit_amount, month, year)
VALUES
  -- USER 1
  (1, 'food', 250.00, 2, 2026),       -- chi 270 => vượt ngân sách
  (1, 'travel', 150.00, 3, 2026),     -- chi 130 => gần hết ngân sách
  (1, 'food', 100.00, 5, 2026),       -- chi 30 => còn dư
  (1, 'travel', 100.00, 5, 2026),     -- chi 20 => còn dư

  -- USER 2
  (2, 'work', 150.00, 2, 2026),       -- chi 200 => vượt ngân sách
  (2, 'food', 180.00, 3, 2026),       -- chi 170 => gần hết ngân sách
  (2, 'food', 100.00, 5, 2026),       -- chi 35 => còn dư

  -- USER 3
  (3, 'leisure', 300.00, 3, 2026),    -- chi 500 => vượt ngân sách
  (3, 'work', 230.00, 4, 2026),       -- chi 200 => gần hết ngân sách
  (3, 'food', 100.00, 5, 2026);       -- chi 40 => còn dư
  -- =========================================================
-- ĐOẠN 6: XEM LẠI DATA
-- =========================================================

USE expense_manager;

SELECT * FROM users;
SELECT * FROM expenses;
SELECT * FROM budgets;