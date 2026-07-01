-- SQL Practice Lab: Retail Data Warehouse Schema
-- PostgreSQL 16+

BEGIN;

CREATE SCHEMA IF NOT EXISTS retail;
SET search_path TO retail, public;

-- ---------------------------------------------------------------------------
-- Reference / dimension tables
-- ---------------------------------------------------------------------------

CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    department_code VARCHAR(10)  NOT NULL UNIQUE,
    department_name VARCHAR(100) NOT NULL,
    location        VARCHAR(100),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE employees (
    employee_id     SERIAL PRIMARY KEY,
    employee_number VARCHAR(20)  NOT NULL UNIQUE,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    department_id   INTEGER      NOT NULL REFERENCES departments(department_id),
    manager_id      INTEGER      REFERENCES employees(employee_id),
    hire_date       DATE         NOT NULL,
    salary          NUMERIC(12, 2),
    terminated_at   DATE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE categories (
    category_id        SERIAL PRIMARY KEY,
    category_code      VARCHAR(20)  NOT NULL UNIQUE,
    category_name      VARCHAR(100) NOT NULL,
    parent_category_id INTEGER      REFERENCES categories(category_id),
    description        TEXT,
    created_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE suppliers (
    supplier_id   SERIAL PRIMARY KEY,
    supplier_code VARCHAR(20)  NOT NULL UNIQUE,
    supplier_name VARCHAR(150) NOT NULL,
    country       VARCHAR(60)  NOT NULL,
    contact_email VARCHAR(150),
    contact_phone VARCHAR(30),
    rating        NUMERIC(3, 2),
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE customers (
    customer_id    SERIAL PRIMARY KEY,
    customer_code  VARCHAR(20)  NOT NULL UNIQUE,
    full_name      VARCHAR(150) NOT NULL,
    email          VARCHAR(150),
    phone          VARCHAR(30),
    country        VARCHAR(60)  NOT NULL,
    region         VARCHAR(20)  NOT NULL,
    city           VARCHAR(80)  NOT NULL,
    sales_channel  VARCHAR(30)  NOT NULL,
    credit_limit   NUMERIC(12, 2),
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_customers_region
        CHECK (region IN ('NA', 'EU', 'LATAM', 'APAC')),
    CONSTRAINT chk_customers_sales_channel
        CHECK (sales_channel IN ('online', 'retail', 'phone', 'wholesale', 'marketplace'))
);

CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    sku             VARCHAR(30)  NOT NULL UNIQUE,
    product_name    VARCHAR(200) NOT NULL,
    category_id     INTEGER      REFERENCES categories(category_id),
    supplier_id     INTEGER      NOT NULL REFERENCES suppliers(supplier_id),
    list_price      NUMERIC(12, 2) NOT NULL,
    cost_price      NUMERIC(12, 2) NOT NULL,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    discontinued_at DATE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_products_prices CHECK (list_price >= 0 AND cost_price >= 0)
);

-- ---------------------------------------------------------------------------
-- Transactional tables
-- ---------------------------------------------------------------------------

CREATE TABLE sales_orders (
    order_id       SERIAL PRIMARY KEY,
    order_number   VARCHAR(30)  NOT NULL UNIQUE,
    customer_id    INTEGER      NOT NULL REFERENCES customers(customer_id),
    employee_id    INTEGER      REFERENCES employees(employee_id),
    order_date     TIMESTAMPTZ  NOT NULL,
    status         VARCHAR(20)  NOT NULL,
    sales_channel  VARCHAR(30)  NOT NULL,
    ship_region    VARCHAR(20)  NOT NULL,
    shipped_at     TIMESTAMPTZ,
    cancelled_at   TIMESTAMPTZ,
    notes          TEXT,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_sales_orders_status
        CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'returned')),
    CONSTRAINT chk_sales_orders_channel
        CHECK (sales_channel IN ('online', 'retail', 'phone', 'wholesale', 'marketplace')),
    CONSTRAINT chk_sales_orders_region
        CHECK (ship_region IN ('NA', 'EU', 'LATAM', 'APAC'))
);

CREATE TABLE sales_order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id      INTEGER        NOT NULL REFERENCES sales_orders(order_id) ON DELETE CASCADE,
    product_id    INTEGER        NOT NULL REFERENCES products(product_id),
    quantity      INTEGER        NOT NULL,
    unit_price    NUMERIC(12, 2) NOT NULL,
    discount_pct  NUMERIC(5, 2),
    line_total    NUMERIC(14, 2) GENERATED ALWAYS AS (
        ROUND(quantity * unit_price * (1 - COALESCE(discount_pct, 0) / 100.0), 2)
    ) STORED,
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_order_items_discount CHECK (discount_pct IS NULL OR (discount_pct >= 0 AND discount_pct <= 100))
);

CREATE TABLE inventory (
    inventory_id        SERIAL PRIMARY KEY,
    product_id          INTEGER      NOT NULL UNIQUE REFERENCES products(product_id),
    warehouse_location  VARCHAR(50)  NOT NULL,
    quantity_on_hand    INTEGER      NOT NULL DEFAULT 0,
    reorder_level       INTEGER      NOT NULL DEFAULT 10,
    last_restocked_at   TIMESTAMPTZ,
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE payments (
    payment_id     SERIAL PRIMARY KEY,
    order_id       INTEGER        NOT NULL REFERENCES sales_orders(order_id),
    payment_date   TIMESTAMPTZ    NOT NULL,
    amount         NUMERIC(12, 2) NOT NULL,
    payment_method VARCHAR(30)    NOT NULL,
    status         VARCHAR(20)    NOT NULL,
    reference_no   VARCHAR(50),
    created_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_payments_amount CHECK (amount >= 0),
    CONSTRAINT chk_payments_method
        CHECK (payment_method IN ('credit_card', 'debit_card', 'bank_transfer', 'paypal', 'cash', 'check')),
    CONSTRAINT chk_payments_status
        CHECK (status IN ('pending', 'completed', 'failed', 'refunded', 'partial'))
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

CREATE INDEX idx_employees_department_id   ON employees(department_id);
CREATE INDEX idx_employees_manager_id      ON employees(manager_id);
CREATE INDEX idx_categories_parent_id      ON categories(parent_category_id);
CREATE INDEX idx_products_category_id      ON products(category_id);
CREATE INDEX idx_products_supplier_id      ON products(supplier_id);
CREATE INDEX idx_customers_region          ON customers(region);
CREATE INDEX idx_customers_sales_channel   ON customers(sales_channel);
CREATE INDEX idx_customers_email           ON customers(email);
CREATE INDEX idx_sales_orders_customer_id  ON sales_orders(customer_id);
CREATE INDEX idx_sales_orders_employee_id  ON sales_orders(employee_id);
CREATE INDEX idx_sales_orders_order_date   ON sales_orders(order_date);
CREATE INDEX idx_sales_orders_status       ON sales_orders(status);
CREATE INDEX idx_sales_orders_channel      ON sales_orders(sales_channel);
CREATE INDEX idx_sales_orders_region       ON sales_orders(ship_region);
CREATE INDEX idx_order_items_order_id      ON sales_order_items(order_id);
CREATE INDEX idx_order_items_product_id    ON sales_order_items(product_id);
CREATE INDEX idx_payments_order_id         ON payments(order_id);
CREATE INDEX idx_payments_payment_date     ON payments(payment_date);
CREATE INDEX idx_payments_reference_no     ON payments(reference_no);

-- ---------------------------------------------------------------------------
-- Practice views
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_order_summary AS
SELECT
    so.order_id,
    so.order_number,
    so.order_date,
    so.status,
    so.sales_channel,
    so.ship_region,
    c.customer_code,
    c.full_name AS customer_name,
    e.employee_number,
    e.first_name || ' ' || e.last_name AS sales_rep,
    COUNT(soi.order_item_id) AS item_count,
    COALESCE(SUM(soi.line_total), 0) AS order_total
FROM sales_orders so
JOIN customers c ON c.customer_id = so.customer_id
LEFT JOIN employees e ON e.employee_id = so.employee_id
LEFT JOIN sales_order_items soi ON soi.order_id = so.order_id
GROUP BY
    so.order_id, so.order_number, so.order_date, so.status,
    so.sales_channel, so.ship_region,
    c.customer_code, c.full_name,
    e.employee_number, e.first_name, e.last_name;

CREATE OR REPLACE VIEW v_customer_ltv AS
SELECT
    c.customer_id,
    c.customer_code,
    c.full_name,
    c.region,
    c.sales_channel,
    COUNT(DISTINCT so.order_id) AS total_orders,
    MIN(so.order_date) AS first_order_date,
    MAX(so.order_date) AS last_order_date,
    COALESCE(SUM(soi.line_total), 0) AS lifetime_value
FROM customers c
LEFT JOIN sales_orders so ON so.customer_id = c.customer_id
    AND so.status NOT IN ('cancelled', 'returned')
LEFT JOIN sales_order_items soi ON soi.order_id = so.order_id
GROUP BY
    c.customer_id, c.customer_code, c.full_name, c.region, c.sales_channel;

CREATE OR REPLACE VIEW v_data_quality_issues AS
SELECT
    'shipped_without_date' AS issue_type,
    so.order_id,
    so.order_number,
    so.status,
    so.shipped_at,
    NULL::NUMERIC AS extra_amount
FROM sales_orders so
WHERE so.status = 'shipped' AND so.shipped_at IS NULL

UNION ALL

SELECT
    'payment_exceeds_order_total' AS issue_type,
    so.order_id,
    so.order_number,
    so.status,
    NULL::TIMESTAMPTZ,
    pay_sum.total_paid - ord_sum.order_total AS extra_amount
FROM sales_orders so
JOIN (
    SELECT order_id, SUM(line_total) AS order_total
    FROM sales_order_items
    GROUP BY order_id
) ord_sum ON ord_sum.order_id = so.order_id
JOIN (
    SELECT order_id, SUM(amount) AS total_paid
    FROM payments
    WHERE status IN ('completed', 'partial')
    GROUP BY order_id
) pay_sum ON pay_sum.order_id = so.order_id
WHERE pay_sum.total_paid > ord_sum.order_total

UNION ALL

SELECT
    'active_but_discontinued' AS issue_type,
    p.product_id AS order_id,
    p.sku AS order_number,
    CASE WHEN p.is_active THEN 'active' ELSE 'inactive' END AS status,
    p.discontinued_at::TIMESTAMPTZ,
    NULL::NUMERIC
FROM products p
WHERE p.is_active = TRUE AND p.discontinued_at IS NOT NULL

UNION ALL

SELECT
    'duplicate_customer_email' AS issue_type,
    c.customer_id AS order_id,
    c.customer_code AS order_number,
    c.email AS status,
    NULL::TIMESTAMPTZ,
    dup.cnt::NUMERIC
FROM customers c
JOIN (
    SELECT email, COUNT(*) AS cnt
    FROM customers
    WHERE email IS NOT NULL
    GROUP BY email
    HAVING COUNT(*) > 1
) dup ON dup.email = c.email;

COMMIT;
