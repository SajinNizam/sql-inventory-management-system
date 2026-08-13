# Inventory Management System (SQL)

A MySQL-based inventory management system simulating stock tracking, order
processing, and reporting for a small retail business. Built as a hands-on
project to practice core to advanced SQL concepts, from schema design through
stored procedures, triggers, transactions, and window functions.

## Overview

The system tracks products, suppliers, stock levels across warehouses, and
customer orders. It includes business logic to prevent overselling, an
automatic audit trail of every stock change, and reporting views/queries for
analysis.

## Schema

```
suppliers (supplier_id, supplier_name, contact_email)
        |
        | 1-to-many
        v
products (product_id, product_name, category, price, supplier_id)
        |
        | 1-to-many
        v
inventory (inventory_id, product_id, stock, warehouse_location)

products (product_id) --< orders (order_id, customer_name, product_id, qty, order_date)
products (product_id) --< inventory_log (log_id, product_id, change_type, qty_changed, old_stock, new_stock, changed_at)
```

- **suppliers** → **products**: one supplier can supply many products
- **products** → **inventory**: one product has one stock record (per warehouse, in this version)
- **products** → **orders**: one product can appear in many orders
- **products** → **inventory_log**: every stock change for a product is logged

## Skills demonstrated

| Area | Details |
|---|---|
| Schema design | Multi-table schema with primary/foreign keys |
| Joins & aggregation | `JOIN`, `GROUP BY`, `HAVING` |
| Views | Filtered vs. unfiltered reporting views |
| Stored procedures | Parameters, conditional logic (`IF` / `ELSEIF`), input validation |
| Triggers | `AFTER UPDATE` (auto-logging), `BEFORE UPDATE` (data validation / rejecting bad writes) |
| Transactions | `START TRANSACTION`, `COMMIT`, `ROLLBACK`, `SAVEPOINT` / `ROLLBACK TO` |
| Subqueries & CTEs | Correlated subqueries, `WITH ... AS` |
| Window functions | `RANK()`, `ROW_NUMBER()`, `AVG() OVER (PARTITION BY ...)` |

## Key features

- **`PlaceOrder` procedure** — validates a purchase end-to-end: rejects orders
  for products that don't exist ("Item not in list"), rejects orders that
  exceed available stock ("Insufficient stock"), and otherwise reduces stock,
  records the order, and logs the change.
- **`RestockProduct` procedure** — increases stock and logs the before/after
  values to `inventory_log`.
- **Audit trail** — `inventory_log` records every stock change, either via
  the procedures above or automatically via the `after_inventory_update`
  trigger (which also catches direct `UPDATE` statements outside the
  procedures).
- **Data integrity trigger** — `before_inventory_update` rejects any update
  that would push stock negative, regardless of how the update was issued.

> **Known trade-off:** `RestockProduct` and `PlaceOrder` insert their own log
> rows *and* the `AFTER UPDATE` trigger also logs the same change — meaning a
> single call currently produces two log rows for one event (one
> `RESTOCK`/`SALE` row, one `AUTO_ADJUST` row). This was kept intentionally
> during development to compare both logging approaches side by side; a
> production version would use one approach only (most likely trigger-only,
> since it also catches changes made outside the procedures).

## How to run

Run the files in order against a MySQL instance:

1. `01_schema.sql` — creates the database and tables
2. `02_sample_data.sql` — inserts sample suppliers, products, inventory, orders
3. `03_views.sql` — creates the reporting views
4. `04_procedures.sql` — creates the stored procedures
5. `05_triggers.sql` — creates the triggers
6. `06_transactions_demo.sql` — optional; demonstrates `COMMIT`/`ROLLBACK`/`SAVEPOINT`
7. `07_advanced_queries.sql` — subqueries, CTEs, window function examples
8. `08_sample_queries.sql` — basic analysis queries

```bash
mysql -u root -p < 01_schema.sql
mysql -u root -p < 02_sample_data.sql
mysql -u root -p < 03_views.sql
mysql -u root -p < 04_procedures.sql
mysql -u root -p < 05_triggers.sql
```

## Example usage

```sql
-- Find low-stock products
CALL GetLowStockProducts(20);

-- Restock a product
CALL RestockProduct(9, 50);

-- Place an order (with validation)
CALL PlaceOrder('Test Customer', 9, 5);

-- View category-level reporting
SELECT * FROM category_stock_summary_all;

-- Rank products by price within category
SELECT product_name, category, price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank
FROM products;
```

## Tech stack

MySQL 8.0+ (uses window functions and CTEs, which require MySQL 8.0 or later)
