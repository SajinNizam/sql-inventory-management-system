-- =====================================================
-- Inventory Management System — Sample Data
-- =====================================================
USE inventory;

-- Suppliers
INSERT INTO suppliers (supplier_name, contact_email)
VALUES
('ABC Traders', 'abc@traders.com'),
('Global Supply Co', 'contact@globalsupply.com'),
('Metro Distributors', 'sales@metrodist.com'),
('TechSource Ltd', 'info@techsource.com');

-- Products
INSERT INTO products (product_name, category, price, supplier_id)
VALUES
('Laptop', 'Electronics', 55000, 1),
('Office Chair', 'Furniture', 4500, 2),
('Wireless Mouse', 'Electronics', 800, 1),
('Standing Desk', 'Furniture', 12000, 2),
('Monitor 24"', 'Electronics', 9500, 4),
('Keyboard', 'Electronics', 1200, 1),
('Bookshelf', 'Furniture', 3200, 3),
('Desk Lamp', 'Furniture', 950, 3),
('USB-C Hub', 'Electronics', 1800, 4),
('Filing Cabinet', 'Furniture', 6700, 2);

-- Inventory
INSERT INTO inventory (product_id, stock, warehouse_location)
VALUES
(1, 20, 'Warehouse A'),
(2, 15, 'Warehouse B'),
(3, 100, 'Warehouse A'),
(4, 8, 'Warehouse B'),
(5, 35, 'Warehouse A'),
(6, 5, 'Warehouse A'),
(7, 12, 'Warehouse B'),
(8, 40, 'Warehouse B'),
(9, 3, 'Warehouse A'),
(10, 18, 'Warehouse B');

-- Orders
INSERT INTO orders (customer_name, product_id, qty, order_date)
VALUES
('Ravi Kumar', 1, 2, '2026-06-01'),
('Anjali Menon', 3, 5, '2026-06-03'),
('Suresh Nair', 2, 1, '2026-06-05'),
('Priya Das', 5, 3, '2026-06-10'),
('Ajay Pillai', 6, 10, '2026-06-12'),
('Meera S', 4, 1, '2026-06-15'),
('Nikhil Raj', 9, 2, '2026-06-18'),
('Divya Menon', 8, 4, '2026-06-20'),
('Arjun Mohan', 10, 1, '2026-06-22'),
('Lakshmi Iyer', 7, 6, '2026-06-25');
