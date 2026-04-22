CREATE DATABASE expense_manager;

USE expense_manager;
select * from users;
select * from expenses;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE expenses (
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
INSERT INTO expenses (user_id, title, amount, category, expense_date)
VALUES
  (1, 'Lunch', 45.00, 'food', '2026-04-19'),
  (1, 'Grab to school', 80.00, 'travel', '2026-04-20'),
  (1, 'Movie ticket', 120.00, 'leisure', '2026-04-21');