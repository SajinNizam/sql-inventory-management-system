-- =====================================================
-- Inventory Management System — Transaction Control Demos
-- COMMIT, ROLLBACK, SAVEPOINT
-- =====================================================
USE inventory;

-- ---------------------------------------------------------
-- Demo 1: SAVEPOINT + ROLLBACK TO
-- Shows how to undo part of a transaction while keeping
-- earlier changes within the same transaction.
-- ---------------------------------------------------------
START TRANSACTION;

UPDATE inventory SET stock = stock + 100 WHERE product_id = 9;
SAVEPOINT checkpoint1;

UPDATE inventory SET stock = stock - 1000 WHERE product_id = 9;  -- a mistaken update

ROLLBACK TO checkpoint1;  -- undo only the mistaken update, keep the +100

COMMIT;

SELECT stock FROM inventory WHERE product_id = 9;


-- ---------------------------------------------------------
-- Demo 2: COMMIT vs ROLLBACK
-- Shows the basic decision pattern: preview a change inside
-- a transaction, then decide to keep it (COMMIT) or discard
-- it (ROLLBACK).
-- ---------------------------------------------------------

-- Test A: commit a change
START TRANSACTION;
UPDATE inventory SET stock = stock - 10 WHERE product_id = 9;
SELECT stock FROM inventory WHERE product_id = 9;  -- preview
COMMIT;
SELECT stock FROM inventory WHERE product_id = 9;  -- now permanent

-- Test B: discard a change
START TRANSACTION;
UPDATE inventory SET stock = stock - 10 WHERE product_id = 9;
SELECT stock FROM inventory WHERE product_id = 9;  -- preview
ROLLBACK;
SELECT stock FROM inventory WHERE product_id = 9;  -- reverted, unchanged


-- ---------------------------------------------------------
-- Demo 3: Transaction interacting with the BEFORE trigger
-- The bad update below is rejected entirely by
-- before_inventory_update (see 05_triggers.sql) — since it
-- never applies, only the earlier valid change gets committed.
-- ---------------------------------------------------------
START TRANSACTION;

UPDATE inventory SET stock = stock + 20 WHERE product_id = 9;
SAVEPOINT after_good_update;

SELECT stock FROM inventory WHERE product_id = 9;  -- state after the good update

-- The next line is expected to raise 'Stock cannot go negative'
-- and will NOT apply, since before_inventory_update blocks it:
-- UPDATE inventory SET stock = -50 WHERE product_id = 9;

COMMIT;

SELECT stock FROM inventory WHERE product_id = 9;
