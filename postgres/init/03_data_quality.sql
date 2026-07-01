-- Hand-crafted data quality fixtures for SQL practice exercises
SET search_path TO retail, public;

-- Duplicate email customers
INSERT INTO customers (customer_code, full_name, email, phone, country, region, city, sales_channel, credit_limit, created_at) VALUES
    ('CUST-DQ-001', 'John Smith',        'john.smith@email.com', '+1-555-0101', 'USA',         'NA',    'Boston',      'online',      5000.00,  '2021-03-15 10:00:00+00'),
    ('CUST-DQ-002', 'Jonathan Smith Jr', 'john.smith@email.com', '+1-555-0102', 'USA',         'NA',    'Cambridge',   'retail',      3000.00,  '2022-07-20 14:30:00+00'),
    ('CUST-DQ-003', 'Acme Corp',         'billing@acme.com',     '+1-555-0201', 'USA',         'NA',    'New York',    'wholesale',   50000.00, '2020-01-10 09:00:00+00'),
    ('CUST-DQ-004', 'ACME Corp.',        'billing@acme.com',     NULL,          'USA',         'NA',    'New York',    'wholesale',   NULL,     '2020-01-11 09:00:00+00'),
    ('CUST-DQ-005', 'No Orders Customer','noorders@example.com', '+44-20-1234', 'UK',          'EU',    'London',      'online',      1000.00,  '2023-05-01 08:00:00+00');

-- Product with active/discontinued inconsistency
INSERT INTO products (sku, product_name, category_id, supplier_id, list_price, cost_price, is_active, discontinued_at, created_at) VALUES
    ('SKU-DQ-001', 'Ghost Product Active-Discontinued', 10, 3, 299.99, 150.00, TRUE, '2023-06-01', '2020-05-01 00:00:00+00'),
    ('SKU-DQ-002', 'Orphan Category Product',             NULL, 5, 49.99, 25.00, TRUE, NULL,       '2021-01-01 00:00:00+00');

INSERT INTO inventory (product_id, warehouse_location, quantity_on_hand, reorder_level, last_restocked_at) VALUES
    ((SELECT product_id FROM products WHERE sku = 'SKU-DQ-001'), 'WH-EAST', -5, 10, NULL),
    ((SELECT product_id FROM products WHERE sku = 'SKU-DQ-002'), 'WH-WEST', 100, 20, '2024-01-15 12:00:00+00');

-- Orders with data quality issues
INSERT INTO sales_orders (order_number, customer_id, employee_id, order_date, status, sales_channel, ship_region, shipped_at, cancelled_at, notes) VALUES
    ('ORD-DQ-001', (SELECT customer_id FROM customers WHERE customer_code = 'CUST-DQ-001'), 10,
     '2024-03-15 10:00:00+00', 'shipped', 'online', 'NA', NULL, NULL,
     'DATA QUALITY: status shipped but shipped_at is NULL'),
    ('ORD-DQ-002', (SELECT customer_id FROM customers WHERE customer_code = 'CUST-DQ-003'), 11,
     '2024-06-20 14:00:00+00', 'delivered', 'wholesale', 'NA', '2024-06-22 09:00:00+00', NULL,
     'DATA QUALITY: payments exceed order total'),
    ('ORD-DQ-003', (SELECT customer_id FROM customers WHERE customer_code = 'CUST-DQ-002'), 12,
     '2024-08-01 11:00:00+00', 'cancelled', 'retail', 'NA', NULL, '2024-08-02 10:00:00+00',
     'Cancelled order for practice');

INSERT INTO sales_order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
    ((SELECT order_id FROM sales_orders WHERE order_number = 'ORD-DQ-001'),
     (SELECT product_id FROM products WHERE sku = 'SKU-DQ-001'), 2, 299.99, 0),
    ((SELECT order_id FROM sales_orders WHERE order_number = 'ORD-DQ-002'),
     (SELECT product_id FROM products WHERE sku = 'SKU-DQ-002'), 10, 49.99, 5),
    ((SELECT order_id FROM sales_orders WHERE order_number = 'ORD-DQ-003'),
     (SELECT product_id FROM products WHERE sku = 'SKU-DQ-001'), 1, 299.99, 0);

-- Payments: duplicate references and overpayment
INSERT INTO payments (order_id, payment_date, amount, payment_method, status, reference_no) VALUES
    ((SELECT order_id FROM sales_orders WHERE order_number = 'ORD-DQ-002'),
     '2024-06-21 10:00:00+00', 500.00, 'bank_transfer', 'completed', 'REF-2024-001'),
    ((SELECT order_id FROM sales_orders WHERE order_number = 'ORD-DQ-002'),
     '2024-06-22 11:00:00+00', 200.00, 'credit_card',   'completed', 'REF-2024-001'),
    ((SELECT order_id FROM sales_orders WHERE order_number = 'ORD-DQ-001'),
     '2024-03-16 09:00:00+00', 599.98, 'credit_card',   'completed', 'REF-DQ-003'),
    ((SELECT order_id FROM sales_orders WHERE order_number = 'ORD-DQ-003'),
     '2024-08-01 12:00:00+00', 299.99, 'debit_card',    'refunded',  NULL);
