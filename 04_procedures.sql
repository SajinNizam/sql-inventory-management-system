-- =====================================================
-- Inventory Management System — Stored Procedures
-- =====================================================
USE inventory;

-- ---------------------------------------------------------
-- Procedure 1: GetLowStockProducts
-- Returns all products with stock below a given threshold.
-- ---------------------------------------------------------
DELIMITER //

CREATE PROCEDURE GetLowStockProducts(IN stock_threshold INT)
BEGIN
    SELECT p.product_name, i.stock, i.warehouse_location
    FROM products AS p
    JOIN inventory AS i ON p.product_id = i.product_id
    WHERE i.stock < stock_threshold;
END //

DELIMITER ;

-- Example usage:
-- CALL GetLowStockProducts(20);


-- ---------------------------------------------------------
-- Procedure 2: RestockProduct
-- Increases a product's stock and logs the change to
-- inventory_log (old stock, new stock, qty added).
-- ---------------------------------------------------------
DELIMITER //

CREATE PROCEDURE RestockProduct(IN p_product_id INT, IN p_qty INT)
BEGIN
    DECLARE old_stock_val INT;

    -- 1. Save current stock before changing it
    SELECT stock INTO old_stock_val
    FROM inventory
    WHERE product_id = p_product_id;

    -- 2. Update the stock
    UPDATE inventory
    SET stock = stock + p_qty
    WHERE product_id = p_product_id;

    -- 3. Log what just happened
    INSERT INTO inventory_log (product_id, change_type, qty_changed, old_stock, new_stock)
    VALUES (p_product_id, 'RESTOCK', p_qty, old_stock_val, old_stock_val + p_qty);
END //

DELIMITER ;

-- Example usage:
-- CALL RestockProduct(9, 50);


-- ---------------------------------------------------------
-- Procedure 3: PlaceOrder
-- Validates a purchase before committing it:
--   1. Product must exist            -> 'Item not in list'
--   2. Enough stock must be available -> 'Insufficient stock'
--   3. Otherwise -> reduce stock, insert order, log the sale
-- ---------------------------------------------------------
DELIMITER //

CREATE PROCEDURE PlaceOrder(
    IN p_customer_name VARCHAR(50),
    IN p_product_id INT,
    IN p_qty INT
)
BEGIN
    DECLARE current_stock INT;

    -- Step 1: get current stock (NULL if product doesn't exist)
    SELECT stock INTO current_stock
    FROM inventory
    WHERE product_id = p_product_id;

    -- Step 2: check existence first
    IF current_stock IS NULL THEN
        SELECT 'Item not in list' AS message;

    -- Step 3: check stock availability
    ELSEIF current_stock < p_qty THEN
        SELECT 'Insufficient stock' AS message;

    -- Step 4: enough stock — process the order
    ELSE
        UPDATE inventory
        SET stock = stock - p_qty
        WHERE product_id = p_product_id;

        INSERT INTO orders (customer_name, product_id, qty)
        VALUES (p_customer_name, p_product_id, p_qty);

        INSERT INTO inventory_log (product_id, change_type, qty_changed, old_stock, new_stock)
        VALUES (p_product_id, 'SALE', -p_qty, current_stock, current_stock - p_qty);

        SELECT 'Order placed successfully' AS message;
    END IF;
END //

DELIMITER ;

-- Example usage:
-- CALL PlaceOrder('Test Customer', 999, 1);   -- product doesn't exist -> 'Item not in list'
-- CALL PlaceOrder('Test Customer', 9, 1000);  -- not enough stock -> 'Insufficient stock'
-- CALL PlaceOrder('Test Customer', 9, 5);     -- valid -> 'Order placed successfully'
