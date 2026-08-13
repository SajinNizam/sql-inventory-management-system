-- =====================================================
-- Inventory Management System — Views
-- =====================================================
USE inventory;

-- View 1: Filtered — only categories with total stock above 30
-- Useful as a quick "healthy stock" report.
CREATE VIEW category_stock_summary AS
SELECT p.category,
       SUM(i.stock) AS total_stock,
       AVG(p.price) AS average_price
FROM products AS p
JOIN inventory AS i ON p.product_id = i.product_id
GROUP BY p.category
HAVING SUM(i.stock) > 30;

-- View 2: Unfiltered — always shows every category
-- More reusable as a general-purpose base for dashboards/reports;
-- filtering can be applied at query time instead of being baked in.
CREATE VIEW category_stock_summary_all AS
SELECT p.category,
       SUM(i.stock) AS total_stock,
       AVG(p.price) AS average_price
FROM products AS p
JOIN inventory AS i ON p.product_id = i.product_id
GROUP BY p.category;

-- Example usage:
-- SELECT * FROM category_stock_summary;
-- SELECT * FROM category_stock_summary_all;
-- SELECT * FROM category_stock_summary_all WHERE total_stock > 30;  -- filter at query time
