-- SQL Practice Lab: Retail Data Warehouse Schema (Oracle XE port)
-- Mirrors postgres/init/01_schema.sql. Runs automatically on first container
-- start via gvenzl/oracle-xe's /container-entrypoint-initdb.d mechanism.
--
-- IMPORTANT: scripts placed in /container-entrypoint-initdb.d run in SQL*Plus
-- connected AS SYS against the CDB. We switch container + current_schema so
-- every unqualified object below is created inside the SQLSTUDENT schema
-- (the APP_USER created automatically from ORACLE_PASSWORD/APP_USER env vars),
-- instead of ending up owned by SYS.

WHENEVER SQLERROR EXIT SQL.SQLCODE
SET DEFINE OFF

ALTER SESSION SET CONTAINER = XEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = SQLSTUDENT;

-- ---------------------------------------------------------------------------
-- Reference / dimension tables
-- ---------------------------------------------------------------------------

CREATE TABLE departments (
    department_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_code VARCHAR2(10)  NOT NULL UNIQUE,
    department_name VARCHAR2(100) NOT NULL,
    location        VARCHAR2(100),
    created_at      TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE employees (
    employee_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_number VARCHAR2(20)  NOT NULL UNIQUE,
    first_name      VARCHAR2(50)  NOT NULL,
    last_name       VARCHAR2(50)  NOT NULL,
    email           VARCHAR2(150) NOT NULL UNIQUE,
    department_id   NUMBER        NOT NULL REFERENCES departments(department_id),
    manager_id      NUMBER        REFERENCES employees(employee_id),
    hire_date       DATE          NOT NULL,
    salary          NUMBER(12, 2),
    terminated_at   DATE,
    created_at      TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE categories (
    category_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_code      VARCHAR2(20)  NOT NULL UNIQUE,
    category_name      VARCHAR2(100) NOT NULL,
    parent_category_id NUMBER REFERENCES categories(category_id),
    description         CLOB,
    created_at          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE suppliers (
    supplier_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_code VARCHAR2(20)  NOT NULL UNIQUE,
    supplier_name VARCHAR2(150) NOT NULL,
    country       VARCHAR2(60)  NOT NULL,
    contact_email VARCHAR2(150),
    contact_phone VARCHAR2(30),
    rating        NUMBER(3, 2),
    is_active     NUMBER(1)     DEFAULT 1 NOT NULL,
    created_at    TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_suppliers_is_active CHECK (is_active IN (0, 1))
);

CREATE TABLE customers (
    customer_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_code  VARCHAR2(20)  NOT NULL UNIQUE,
    full_name      VARCHAR2(150) NOT NULL,
    email          VARCHAR2(150),
    phone          VARCHAR2(30),
    country        VARCHAR2(60)  NOT NULL,
    region         VARCHAR2(20)  NOT NULL,
    city           VARCHAR2(80)  NOT NULL,
    sales_channel  VARCHAR2(30)  NOT NULL,
    credit_limit   NUMBER(12, 2),
    created_at     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_customers_region
        CHECK (region IN ('NA', 'EU', 'LATAM', 'APAC')),
    CONSTRAINT chk_customers_sales_channel
        CHECK (sales_channel IN ('online', 'retail', 'phone', 'wholesale', 'marketplace'))
);

CREATE TABLE products (
    product_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku             VARCHAR2(30)  NOT NULL UNIQUE,
    product_name    VARCHAR2(200) NOT NULL,
    category_id     NUMBER REFERENCES categories(category_id),
    supplier_id     NUMBER        NOT NULL REFERENCES suppliers(supplier_id),
    list_price      NUMBER(12, 2) NOT NULL,
    cost_price      NUMBER(12, 2) NOT NULL,
    is_active       NUMBER(1)     DEFAULT 1 NOT NULL,
    discontinued_at DATE,
    created_at      TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_products_is_active CHECK (is_active IN (0, 1)),
    CONSTRAINT chk_products_prices CHECK (list_price >= 0 AND cost_price >= 0)
);

-- ---------------------------------------------------------------------------
-- Transactional tables
-- ---------------------------------------------------------------------------

CREATE TABLE sales_orders (
    order_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_number   VARCHAR2(30) NOT NULL UNIQUE,
    customer_id    NUMBER       NOT NULL REFERENCES customers(customer_id),
    employee_id    NUMBER REFERENCES employees(employee_id),
    order_date     TIMESTAMP    NOT NULL,
    status         VARCHAR2(20) NOT NULL,
    sales_channel  VARCHAR2(30) NOT NULL,
    ship_region    VARCHAR2(20) NOT NULL,
    shipped_at     TIMESTAMP,
    cancelled_at   TIMESTAMP,
    notes          CLOB,
    created_at     TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_sales_orders_status
        CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'returned')),
    CONSTRAINT chk_sales_orders_channel
        CHECK (sales_channel IN ('online', 'retail', 'phone', 'wholesale', 'marketplace')),
    CONSTRAINT chk_sales_orders_region
        CHECK (ship_region IN ('NA', 'EU', 'LATAM', 'APAC'))
);

CREATE TABLE sales_order_items (
    order_item_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      NUMBER         NOT NULL REFERENCES sales_orders(order_id) ON DELETE CASCADE,
    product_id    NUMBER         NOT NULL REFERENCES products(product_id),
    quantity      NUMBER         NOT NULL,
    unit_price    NUMBER(12, 2)  NOT NULL,
    discount_pct  NUMBER(5, 2),
    line_total    NUMBER(14, 2) GENERATED ALWAYS AS (
        ROUND(quantity * unit_price * (1 - NVL(discount_pct, 0) / 100), 2)
    ) VIRTUAL,
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_order_items_discount CHECK (discount_pct IS NULL OR (discount_pct >= 0 AND discount_pct <= 100))
);

CREATE TABLE inventory (
    inventory_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id         NUMBER      NOT NULL UNIQUE REFERENCES products(product_id),
    warehouse_location VARCHAR2(50) NOT NULL,
    quantity_on_hand   NUMBER      DEFAULT 0 NOT NULL,
    reorder_level      NUMBER      DEFAULT 10 NOT NULL,
    last_restocked_at  TIMESTAMP,
    updated_at         TIMESTAMP   DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE payments (
    payment_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id       NUMBER        NOT NULL REFERENCES sales_orders(order_id),
    payment_date   TIMESTAMP     NOT NULL,
    amount         NUMBER(12, 2) NOT NULL,
    payment_method VARCHAR2(30)  NOT NULL,
    status         VARCHAR2(20)  NOT NULL,
    reference_no   VARCHAR2(50),
    created_at     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_payments_amount CHECK (amount >= 0),
    CONSTRAINT chk_payments_method
        CHECK (payment_method IN ('credit_card', 'debit_card', 'bank_transfer', 'paypal', 'cash', 'check')),
    CONSTRAINT chk_payments_status
        CHECK (status IN ('pending', 'completed', 'failed', 'refunded', 'partial'))
);

-- ---------------------------------------------------------------------------
-- Indexes (Oracle does not auto-index FK columns the way PKs are indexed)
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
    NVL(SUM(soi.line_total), 0) AS order_total
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
    NVL(SUM(soi.line_total), 0) AS lifetime_value
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
    CAST(NULL AS NUMBER(14,2)) AS extra_amount
FROM sales_orders so
WHERE so.status = 'shipped' AND so.shipped_at IS NULL

UNION ALL

SELECT
    'payment_exceeds_order_total' AS issue_type,
    so.order_id,
    so.order_number,
    so.status,
    CAST(NULL AS TIMESTAMP) AS shipped_at,
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
    CASE WHEN p.is_active = 1 THEN 'active' ELSE 'inactive' END AS status,
    CAST(p.discontinued_at AS TIMESTAMP) AS shipped_at,
    CAST(NULL AS NUMBER(14,2)) AS extra_amount
FROM products p
WHERE p.is_active = 1 AND p.discontinued_at IS NOT NULL

UNION ALL

SELECT
    'duplicate_customer_email' AS issue_type,
    c.customer_id AS order_id,
    c.customer_code AS order_number,
    c.email AS status,
    CAST(NULL AS TIMESTAMP) AS shipped_at,
    CAST(dup.cnt AS NUMBER(14,2)) AS extra_amount
FROM customers c
JOIN (
    SELECT email, COUNT(*) AS cnt
    FROM customers
    WHERE email IS NOT NULL
    GROUP BY email
    HAVING COUNT(*) > 1
) dup ON dup.email = c.email;

COMMIT;

EXIT;
