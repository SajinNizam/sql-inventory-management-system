-- =====================================================
-- Inventory Management System — Triggers
-- =====================================================
USE inventory;

-- ---------------------------------------------------------
-- Trigger 1: after_inventory_update  (AFTER UPDATE)
-- Automatically logs any stock change to inventory_log,
-- even changes made outside the stored procedures (e.g. a
-- raw UPDATE run directly against the inventory table).
--
-- NOTE: RestockProduct and PlaceOrder already insert their
-- own log rows manually. Combined with this trigger, a call
-- to either procedure will produce TWO log rows for the same
-- change (one manual, one AUTO_ADJUST from the trigger).
-- Kept intentionally in this project as a learning exercise —
-- in a production system you'd pick one approach only
-- (trigger-only is usually the cleaner choice, since it also
-- catches changes made outside the procedures).
-- ---------------------------------------------------------
DELIMITER //

CREATE TRIGGER after_inventory_update
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
    IF NEW.stock <> OLD.stock THEN
        INSERT INTO inventory_log (product_id, change_type, qty_changed, old_stock, new_stock)
        VALUES (NEW.product_id, 'AUTO_ADJUST', NEW.stock - OLD.stock, OLD.stock, NEW.stock);
    END IF;
END //

DELIMITER ;


-- ---------------------------------------------------------
-- Trigger 2: before_inventory_update  (BEFORE UPDATE)
-- Blocks any update that would push stock below zero,
-- rejecting the statement with a custom error instead of
-- silently allowing bad data.
-- ---------------------------------------------------------
DELIMITER //

CREATE TRIGGER before_inventory_update
BEFORE UPDATE ON inventory
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock cannot go negative';
    END IF;
END //

DELIMITER ;

-- Example usage / test:
-- UPDATE inventory SET stock = stock + 15 WHERE product_id = 3;   -- auto-logged by AFTER trigger
-- UPDATE inventory SET stock = -50 WHERE product_id = 9;          -- rejected by BEFORE trigger
