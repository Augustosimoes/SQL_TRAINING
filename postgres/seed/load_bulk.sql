-- Bulk data load script (run via setup.ps1 / setup.sh after CSV generation)
-- Resolves foreign keys via natural keys (customer_code, sku, order_number)

SET search_path TO retail, public;

CREATE TEMP TABLE stg_customers (
    customer_code  VARCHAR(20),
    full_name      VARCHAR(150),
    email          VARCHAR(150),
    phone          VARCHAR(30),
    country        VARCHAR(60),
    region         VARCHAR(20),
    city           VARCHAR(80),
    sales_channel  VARCHAR(30),
    credit_limit   TEXT,
    created_at     TIMESTAMPTZ
);

CREATE TEMP TABLE stg_products (
    sku              VARCHAR(30),
    product_name     VARCHAR(200),
    category_id      TEXT,
    supplier_id      INTEGER,
    list_price       NUMERIC(12, 2),
    cost_price       NUMERIC(12, 2),
    is_active        TEXT,
    discontinued_at  TEXT,
    created_at       TIMESTAMPTZ
);

CREATE TEMP TABLE stg_sales_orders (
    order_number   VARCHAR(30),
    customer_code  VARCHAR(20),
    employee_id    TEXT,
    order_date     TIMESTAMPTZ,
    status         VARCHAR(20),
    sales_channel  VARCHAR(30),
    ship_region    VARCHAR(20),
    shipped_at     TEXT,
    cancelled_at   TEXT,
    notes          TEXT
);

CREATE TEMP TABLE stg_sales_order_items (
    order_number  VARCHAR(30),
    sku           VARCHAR(30),
    quantity      INTEGER,
    unit_price    NUMERIC(12, 2),
    discount_pct  TEXT
);

CREATE TEMP TABLE stg_inventory_raw (
    product_id          INTEGER,
    warehouse_location  VARCHAR(50),
    quantity_on_hand    INTEGER,
    reorder_level       INTEGER,
    last_restocked_at   TEXT
);

CREATE TEMP TABLE stg_payments (
    order_number    VARCHAR(30),
    payment_date    TIMESTAMPTZ,
    amount          NUMERIC(12, 2),
    payment_method  VARCHAR(30),
    status          VARCHAR(20),
    reference_no    TEXT
);

\copy stg_customers FROM '/seed/data/customers.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy stg_products FROM '/seed/data/products.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy stg_sales_orders FROM '/seed/data/sales_orders.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy stg_sales_order_items FROM '/seed/data/sales_order_items.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy stg_inventory_raw FROM '/seed/data/inventory.csv' WITH (FORMAT csv, HEADER true, NULL '')
\copy stg_payments FROM '/seed/data/payments.csv' WITH (FORMAT csv, HEADER true, NULL '')

INSERT INTO customers (customer_code, full_name, email, phone, country, region, city, sales_channel, credit_limit, created_at)
SELECT customer_code, full_name, NULLIF(email, ''), NULLIF(phone, ''), country, region, city, sales_channel,
       NULLIF(credit_limit, '')::NUMERIC, created_at
FROM stg_customers
ON CONFLICT (customer_code) DO NOTHING;

INSERT INTO products (sku, product_name, category_id, supplier_id, list_price, cost_price, is_active, discontinued_at, created_at)
SELECT sku, product_name,
       NULLIF(category_id, '')::INTEGER,
       supplier_id, list_price, cost_price,
       CASE WHEN LOWER(is_active) = 'true' THEN TRUE ELSE FALSE END,
       NULLIF(discontinued_at, '')::DATE, created_at
FROM stg_products
ON CONFLICT (sku) DO NOTHING;

INSERT INTO sales_orders (order_number, customer_id, employee_id, order_date, status, sales_channel, ship_region, shipped_at, cancelled_at, notes)
SELECT s.order_number, c.customer_id,
       NULLIF(s.employee_id, '')::INTEGER,
       s.order_date, s.status, s.sales_channel, s.ship_region,
       NULLIF(s.shipped_at, '')::TIMESTAMPTZ,
       NULLIF(s.cancelled_at, '')::TIMESTAMPTZ,
       NULLIF(s.notes, '')
FROM stg_sales_orders s
JOIN customers c ON c.customer_code = s.customer_code
ON CONFLICT (order_number) DO NOTHING;

INSERT INTO sales_order_items (order_id, product_id, quantity, unit_price, discount_pct)
SELECT so.order_id, p.product_id, i.quantity, i.unit_price,
       NULLIF(i.discount_pct, '')::NUMERIC
FROM stg_sales_order_items i
JOIN sales_orders so ON so.order_number = i.order_number
JOIN products p ON p.sku = i.sku;

INSERT INTO inventory (product_id, warehouse_location, quantity_on_hand, reorder_level, last_restocked_at)
SELECT p.product_id, r.warehouse_location, r.quantity_on_hand, r.reorder_level,
       NULLIF(r.last_restocked_at, '')::TIMESTAMPTZ
FROM stg_inventory_raw r
JOIN products p ON p.sku = 'SKU-' || LPAD(r.product_id::TEXT, 5, '0')
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO payments (order_id, payment_date, amount, payment_method, status, reference_no)
SELECT so.order_id, pay.payment_date, pay.amount, pay.payment_method, pay.status,
       NULLIF(pay.reference_no, '')
FROM stg_payments pay
JOIN sales_orders so ON so.order_number = pay.order_number;

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sales_orders', COUNT(*) FROM sales_orders
UNION ALL SELECT 'sales_order_items', COUNT(*) FROM sales_order_items
UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL SELECT 'payments', COUNT(*) FROM payments
ORDER BY table_name;
