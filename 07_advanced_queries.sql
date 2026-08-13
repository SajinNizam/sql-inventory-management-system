-- =====================================================
-- Inventory Management System — Advanced Queries
-- Subqueries, CTEs, Window Functions
-- =====================================================
USE inventory;

-- ---------------------------------------------------------
-- Correlated subquery:
-- Find products priced above their category's average price.
-- ---------------------------------------------------------
SELECT product_name, category, price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products AS p2
    WHERE p2.category = products.category
);

-- ---------------------------------------------------------
-- Same result using a CTE (Common Table Expression) —
-- more readable than nesting the subquery inline.
-- ---------------------------------------------------------
WITH category_avg AS (
    SELECT category, AVG(price) AS avg_price
    FROM products
    GROUP BY category
)
SELECT p.product_name, p.category, p.price
FROM products AS p
JOIN category_avg AS c ON p.category = c.category
WHERE p.price > c.avg_price;

-- ---------------------------------------------------------
-- Window function: RANK products by price within their category.
-- Unlike GROUP BY, no rows are collapsed — every product still
-- appears, alongside its rank within its category.
-- ---------------------------------------------------------
SELECT product_name, category, price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank
FROM products;

-- ---------------------------------------------------------
-- Window function: show each product's price alongside its
-- category's average price — same result as the CTE/JOIN
-- above, but in a single query with no join needed.
-- ---------------------------------------------------------
SELECT product_name, category, price,
       AVG(price) OVER (PARTITION BY category) AS category_avg_price
FROM products;

-- ---------------------------------------------------------
-- ROW_NUMBER() — like RANK(), but never repeats a number even
-- when prices tie (RANK gives ties the same number and skips
-- the next rank; ROW_NUMBER always counts 1,2,3,4...).
-- ---------------------------------------------------------
SELECT product_name, category, price,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS row_num
FROM products;

-- ---------------------------------------------------------
-- Practical use: top 2 most expensive products per category.
-- Window functions can't be filtered directly in WHERE (they
-- run after WHERE is evaluated), so the ranked result is
-- wrapped in a subquery and filtered in the outer query.
-- ---------------------------------------------------------
SELECT * FROM (
    SELECT product_name, category, price,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rn
    FROM products
) AS ranked
WHERE rn <= 2;
