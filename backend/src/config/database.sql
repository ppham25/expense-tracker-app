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
DELETE FROM expenses;

INSERT INTO expenses (user_id, title, amount, category, expense_date)
VALUES
  -- USER 1 : February 2026 (5 expenses)
  (1, 'Lunch rice', 45.00, 'food', '2026-02-03'),
  (1, 'Bus ticket', 20.00, 'travel', '2026-02-08'),
  (1, 'Notebook', 60.00, 'work', '2026-02-14'),
  (1, 'Milk tea', 55.00, 'food', '2026-02-20'),
  (1, 'Movie ticket', 120.00, 'leisure', '2026-02-25'),

  -- USER 1 : March 2026 (5 expenses)
  (1, 'Breakfast banh mi', 25.00, 'food', '2026-03-02'),
  (1, 'Grab to school', 75.00, 'travel', '2026-03-06'),
  (1, 'Printing documents', 40.00, 'work', '2026-03-11'),
  (1, 'Coffee with team', 65.00, 'work', '2026-03-18'),
  (1, 'Game top-up', 180.00, 'leisure', '2026-03-27'),

  -- USER 1 : April 2026 (many expenses, all <= 2026-04-22)
  (1, 'Breakfast', 30.00, 'food', '2026-04-01'),
  (1, 'Bus fare', 15.00, 'travel', '2026-04-02'),
  (1, 'Lunch', 45.00, 'food', '2026-04-03'),
  (1, 'Photocopy documents', 25.00, 'work', '2026-04-04'),
  (1, 'Milk tea', 50.00, 'food', '2026-04-05'),
  (1, 'Grab to campus', 70.00, 'travel', '2026-04-07'),
  (1, 'Stationery', 85.00, 'work', '2026-04-09'),
  (1, 'Snacks', 35.00, 'food', '2026-04-10'),
  (1, 'Streaming subscription', 99.00, 'leisure', '2026-04-12'),
  (1, 'Lunch noodles', 55.00, 'food', '2026-04-14'),
  (1, 'Taxi home', 110.00, 'travel', '2026-04-16'),
  (1, 'Team coffee', 90.00, 'work', '2026-04-18'),
  (1, 'Lunch', 45.00, 'food', '2026-04-19'),
  (1, 'Grab to school', 80.00, 'travel', '2026-04-20'),
  (1, 'Movie ticket', 120.00, 'leisure', '2026-04-21'),
  (1, 'New earphones', 650.00, 'leisure', '2026-04-22'),

  -- USER 2 : February 2026
  (2, 'Banh mi breakfast', 20.00, 'food', '2026-02-05'),
  (2, 'Motorbike fuel', 70.00, 'travel', '2026-02-10'),
  (2, 'USB cable', 45.00, 'work', '2026-02-17'),
  (2, 'Cinema', 140.00, 'leisure', '2026-02-23'),

  -- USER 2 : March 2026
  (2, 'Lunch rice', 50.00, 'food', '2026-03-04'),
  (2, 'Parking fee', 10.00, 'travel', '2026-03-08'),
  (2, 'Notebook', 35.00, 'work', '2026-03-15'),
  (2, 'Arcade games', 160.00, 'leisure', '2026-03-22'),
  (2, 'Milk tea', 45.00, 'food', '2026-03-29'),

  -- USER 2 : April 2026
  (2, 'Breakfast pho', 40.00, 'food', '2026-04-02'),
  (2, 'Grab to office', 85.00, 'travel', '2026-04-06'),
  (2, 'Printing files', 30.00, 'work', '2026-04-11'),
  (2, 'BBQ dinner', 260.00, 'food', '2026-04-17'),
  (2, 'Concert ticket', 500.00, 'leisure', '2026-04-22');