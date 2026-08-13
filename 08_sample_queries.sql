-- =====================================================
-- Inventory Management System — Sample Analysis Queries
-- =====================================================
USE inventory;

-- Show product name, stock, and warehouse location for all
-- products with stock below 20.
SELECT p.product_name, i.stock, i.warehouse_location
FROM products AS p
JOIN inventory AS i ON p.product_id = i.product_id
WHERE i.stock < 20;

-- Show each category's total stock and average price, but
-- only for categories where total stock is above 30.
SELECT p.category,
       SUM(i.stock) AS category_total_stock,
       AVG(p.price) AS average_price
FROM products AS p
JOIN inventory AS i ON p.product_id = i.product_id
GROUP BY p.category
HAVING SUM(i.stock) > 30;
