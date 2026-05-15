DROP DATABASE IF EXISTS expense_manager;

CREATE DATABASE expense_manager;

USE expense_manager;

-- =========================================================
-- 1. BẢNG NGƯỜI DÙNG
-- =========================================================
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- 2. BẢNG DANH MỤC CHI TIÊU
-- Mỗi user có danh sách category riêng.
-- Không cho 1 user tạo trùng tên category.
-- =========================================================
CREATE TABLE IF NOT EXISTS categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_categories_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,

  CONSTRAINT uq_user_category_name
    UNIQUE (user_id, name)
);

-- =========================================================
-- 3. BẢNG CHI TIÊU
-- category_id liên kết tới bảng categories.
-- =========================================================
CREATE TABLE IF NOT EXISTS expenses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  category_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  expense_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_expenses_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_expenses_category
    FOREIGN KEY (category_id) REFERENCES categories(id)
    ON DELETE RESTRICT
);

-- =========================================================
-- 4. BẢNG NGÂN SÁCH
-- Mỗi user chỉ có 1 budget cho 1 category trong 1 tháng/năm.
-- =========================================================
CREATE TABLE IF NOT EXISTS budgets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  category_id INT NOT NULL,
  limit_amount DECIMAL(10,2) NOT NULL,
  month INT NOT NULL,
  year INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_budgets_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_budgets_category
    FOREIGN KEY (category_id) REFERENCES categories(id)
    ON DELETE RESTRICT,

  CONSTRAINT uq_user_category_month_year
    UNIQUE (user_id, category_id, month, year)
);

-- =========================================================
-- 5. DATA MẪU
-- Mật khẩu hash chỉ để có dữ liệu mẫu, khi demo có thể đăng ký user mới.
-- =========================================================


INSERT INTO categories (user_id, name)
VALUES
  (1, 'food'), (1, 'travel'), (1, 'leisure'), (1, 'work'),
  (2, 'food'), (2, 'travel'), (2, 'leisure'), (2, 'work'),
  (3, 'food'), (3, 'travel'), (3, 'leisure'), (3, 'work');

INSERT INTO expenses (user_id, title, amount, category_id, expense_date)
VALUES
  -- USER 1 : December 2025
  (1, 'Coffee', 50.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'food'), '2025-12-05'),
  (1, 'Bus ticket', 20.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'travel'), '2025-12-10'),
  (1, 'Book', 120.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'work'), '2025-12-15'),

  -- USER 1 : January 2026
  (1, 'Lunch', 60.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'food'), '2026-01-03'),
  (1, 'Taxi', 150.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'travel'), '2026-01-12'),
  (1, 'Movie', 200.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'leisure'), '2026-01-20'),

  -- USER 1 : February 2026
  (1, 'Breakfast', 80.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'food'), '2026-02-01'),
  (1, 'Lunch', 90.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'food'), '2026-02-10'),
  (1, 'Dinner', 100.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'food'), '2026-02-14'),
  (1, 'Grab', 60.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'travel'), '2026-02-18'),

  -- USER 1 : March 2026
  (1, 'Bus', 40.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'travel'), '2026-03-05'),
  (1, 'Grab', 90.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'travel'), '2026-03-10'),
  (1, 'Lunch', 70.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'food'), '2026-03-12'),

  -- USER 1 : April 2026
  (1, 'Game', 300.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'leisure'), '2026-04-02'),
  (1, 'Milk tea', 45.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'food'), '2026-04-10'),

  -- USER 1 : May 2026
  (1, 'Breakfast', 30.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'food'), '2026-05-01'),
  (1, 'Bus', 20.00, (SELECT id FROM categories WHERE user_id = 1 AND name = 'travel'), '2026-05-05'),

  -- USER 2 : December 2025
  (2, 'Pho', 40.00, (SELECT id FROM categories WHERE user_id = 2 AND name = 'food'), '2025-12-08'),
  (2, 'Gas', 70.00, (SELECT id FROM categories WHERE user_id = 2 AND name = 'travel'), '2025-12-18'),

  -- USER 2 : January 2026
  (2, 'Lunch', 55.00, (SELECT id FROM categories WHERE user_id = 2 AND name = 'food'), '2026-01-07'),
  (2, 'Cinema', 120.00, (SELECT id FROM categories WHERE user_id = 2 AND name = 'leisure'), '2026-01-15'),

  -- USER 2 : February 2026
  (2, 'USB', 200.00, (SELECT id FROM categories WHERE user_id = 2 AND name = 'work'), '2026-02-11'),
  (2, 'Coffee', 30.00, (SELECT id FROM categories WHERE user_id = 2 AND name = 'food'), '2026-02-20'),

  -- USER 2 : March 2026
  (2, 'Lunch', 90.00, (SELECT id FROM categories WHERE user_id = 2 AND name = 'food'), '2026-03-03'),
  (2, 'Dinner', 80.00, (SELECT id FROM categories WHERE user_id = 2 AND name = 'food'), '2026-03-14'),

  -- USER 2 : April 2026
  (2, 'Taxi', 150.00, (SELECT id FROM categories WHERE user_id = 2 AND name = 'travel'), '2026-04-09'),

  -- USER 2 : May 2026
  (2, 'Breakfast', 35.00, (SELECT id FROM categories WHERE user_id = 2 AND name = 'food'), '2026-05-10'),

  -- USER 3 : January 2026
  (3, 'Lunch', 60.00, (SELECT id FROM categories WHERE user_id = 3 AND name = 'food'), '2026-01-05'),
  (3, 'Bus', 25.00, (SELECT id FROM categories WHERE user_id = 3 AND name = 'travel'), '2026-01-15'),

  -- USER 3 : February 2026
  (3, 'Dinner', 70.00, (SELECT id FROM categories WHERE user_id = 3 AND name = 'food'), '2026-02-14'),
  (3, 'Movie', 180.00, (SELECT id FROM categories WHERE user_id = 3 AND name = 'leisure'), '2026-02-20'),

  -- USER 3 : March 2026
  (3, 'Concert', 500.00, (SELECT id FROM categories WHERE user_id = 3 AND name = 'leisure'), '2026-03-12'),

  -- USER 3 : April 2026
  (3, 'Notebook', 140.00, (SELECT id FROM categories WHERE user_id = 3 AND name = 'work'), '2026-04-12'),
  (3, 'Pen', 60.00, (SELECT id FROM categories WHERE user_id = 3 AND name = 'work'), '2026-04-14'),

  -- USER 3 : May 2026
  (3, 'Coffee', 40.00, (SELECT id FROM categories WHERE user_id = 3 AND name = 'food'), '2026-05-12');

INSERT INTO budgets (user_id, category_id, limit_amount, month, year)
VALUES
  -- USER 1
  (1, (SELECT id FROM categories WHERE user_id = 1 AND name = 'food'), 250.00, 2, 2026),
  (1, (SELECT id FROM categories WHERE user_id = 1 AND name = 'travel'), 150.00, 3, 2026),
  (1, (SELECT id FROM categories WHERE user_id = 1 AND name = 'food'), 100.00, 5, 2026),
  (1, (SELECT id FROM categories WHERE user_id = 1 AND name = 'travel'), 100.00, 5, 2026),

  -- USER 2
  (2, (SELECT id FROM categories WHERE user_id = 2 AND name = 'work'), 150.00, 2, 2026),
  (2, (SELECT id FROM categories WHERE user_id = 2 AND name = 'food'), 180.00, 3, 2026),
  (2, (SELECT id FROM categories WHERE user_id = 2 AND name = 'food'), 100.00, 5, 2026),

  -- USER 3
  (3, (SELECT id FROM categories WHERE user_id = 3 AND name = 'leisure'), 300.00, 3, 2026),
  (3, (SELECT id FROM categories WHERE user_id = 3 AND name = 'work'), 230.00, 4, 2026),
  (3, (SELECT id FROM categories WHERE user_id = 3 AND name = 'food'), 100.00, 5, 2026);
  
  USE expense_manager;

CREATE TABLE IF NOT EXISTS budget_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  status ENUM('noBudget', 'safe', 'watch', 'warning', 'over') NOT NULL,
  message_type VARCHAR(50) DEFAULT 'funny',
  content VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO budget_messages (status, message_type, content) VALUES
('noBudget', 'funny', 'Ví chưa có hàng rào bảo vệ đó 😆 Đặt budget ngay thôi!'),
('noBudget', 'tip', 'Chi tiêu đang chạy tự do rồi nha, set budget để kiểm soát ví nào!'),
('noBudget', 'funny', 'Chưa có budget mà vẫn tiêu đều tay, ví hơi run rồi đó 😅'),

('safe', 'funny', 'Ổn áp, ví vẫn đang thở đều 😎'),
('safe', 'tip', 'Chi tiêu đang rất đẹp, cứ giữ phong độ này nhé!'),
('safe', 'tip', 'Ví còn khỏe, bạn đang kiểm soát tốt đó.'),

('watch', 'warning', 'Bắt đầu cần để ý rồi nha 👀'),
('watch', 'tip', 'Ví đang nhắc nhẹ: tiêu chậm lại chút nào.'),
('watch', 'warning', 'Chưa nguy hiểm, nhưng cũng không nên chủ quan đâu.'),

('warning', 'warning', 'Cẩn thận, ví bắt đầu rén rồi đó 😬'),
('warning', 'tip', 'Sắp chạm giới hạn rồi, đi nhẹ nói khẽ tiêu ít thôi.'),
('warning', 'funny', 'Budget đang đỏ mặt rồi nha!'),

('over', 'warning', 'Cháy ví rồi! Tháng này hơi căng nha 🔥'),
('over', 'warning', 'Vượt budget rồi, ví cần được cấp cứu!'),
('over', 'funny', 'Tháng này tiêu hơi sung rồi đó 😭');

-- =========================================================
-- 6. XEM LẠI DATA
-- =========================================================
SELECT * FROM users;
SELECT * FROM categories;
SELECT * FROM budget_messages;

SELECT
  e.id,
  e.user_id,
  e.title,
  e.amount,
  e.category_id,
  c.name AS category,
  e.expense_date
FROM expenses e
JOIN categories c ON e.category_id = c.id;
SELECT
  b.id,
  b.user_id,
  b.category_id,
  c.name AS category,
  b.limit_amount,
  b.month,
  b.year
FROM budgets b
JOIN categories c ON b.category_id = c.id;
