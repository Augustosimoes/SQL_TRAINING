-- Dimension seed data: departments, categories, suppliers, employees (Oracle port)
-- Mirrors postgres/init/02_dimensions.sql. IDENTITY columns auto-assign
-- sequential IDs on this fresh table, so row order below intentionally
-- matches the PostgreSQL version: parents before children, managers before
-- their reports, so literal FK references (parent_category_id, manager_id)
-- line up with the IDs Oracle will generate.

WHENEVER SQLERROR EXIT SQL.SQLCODE
SET DEFINE OFF

ALTER SESSION SET CONTAINER = XEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = SQLSTUDENT;

-- Departments (8)
INSERT INTO departments (department_code, department_name, location) VALUES ('FIN',  'Finance',           'New York HQ');
INSERT INTO departments (department_code, department_name, location) VALUES ('SAL',  'Sales',             'Chicago Office');
INSERT INTO departments (department_code, department_name, location) VALUES ('IT',   'Information Tech',  'San Francisco');
INSERT INTO departments (department_code, department_name, location) VALUES ('WH',   'Warehouse',         'Dallas DC');
INSERT INTO departments (department_code, department_name, location) VALUES ('HR',   'Human Resources',   'New York HQ');
INSERT INTO departments (department_code, department_name, location) VALUES ('MKT',  'Marketing',         'Los Angeles');
INSERT INTO departments (department_code, department_name, location) VALUES ('OPS',  'Operations',        'Atlanta');
INSERT INTO departments (department_code, department_name, location) VALUES ('CS',   'Customer Service',  'Phoenix');

-- Categories (24, two levels; parents 1-8 first, children reference them)
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('ELEC',   'Electronics',        NULL, 'Consumer electronics');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('HOME',   'Home & Garden',      NULL, 'Home improvement and garden');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('CLTH',   'Clothing',           NULL, 'Apparel and accessories');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('FOOD',   'Food & Beverage',    NULL, 'Grocery and beverages');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('SPRT',   'Sports',             NULL, 'Sports and outdoors');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('BOOK',   'Books & Media',      NULL, 'Books, music, and media');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('HLTH',   'Health & Beauty',    NULL, 'Health and personal care');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('AUTO',   'Automotive',         NULL, 'Auto parts and accessories');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('PHONES', 'Phones & Tablets',   1,    'Mobile devices');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('COMP',   'Computers',          1,    'Laptops and desktops');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('AUDIO',  'Audio',              1,    'Headphones and speakers');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('TV',     'TV & Video',         1,    'Televisions and streaming');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('FURN',   'Furniture',          2,    'Indoor and outdoor furniture');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('KITC',   'Kitchen',            2,    'Kitchen appliances and tools');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('GARD',   'Garden',             2,    'Garden tools and supplies');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('MENS',   'Men''s Clothing',    3,    'Men''s apparel');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('WMNS',   'Women''s Clothing',  3,    'Women''s apparel');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('SHOE',   'Footwear',           3,    'Shoes and boots');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('SNACK',  'Snacks',             4,    'Packaged snacks');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('BEV',    'Beverages',          4,    'Drinks and beverages');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('FIT',    'Fitness',            5,    'Fitness equipment');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('CAMP',   'Camping',            5,    'Camping and hiking gear');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('SKIN',   'Skincare',           7,    'Skincare products');
INSERT INTO categories (category_code, category_name, parent_category_id, description) VALUES ('SUPP',   'Supplements',        7,    'Vitamins and supplements');

-- Suppliers (35)
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-001', 'Pacific Components Ltd',    'Japan',       'sales@pacificcomp.jp',      '+81-3-1234-5678',   4.50, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-002', 'EuroTech Supplies',         'Germany',     'info@eurotech.de',          '+49-30-9876543',    4.20, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-003', 'Americas Wholesale Inc',    'USA',         'orders@amwholesale.com',    '+1-312-555-0100',   4.80, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-004', 'Shenzhen Electronics Co',   'China',       'export@szelec.cn',          '+86-755-88889999',  4.00, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-005', 'Nordic Home Goods',         'Sweden',      'hello@nordichome.se',       '+46-8-1234567',     4.60, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-006', 'Brazilian Naturals SA',     'Brazil',      'contato@brnaturals.com.br', '+55-11-3333-4444',  3.90, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-007', 'UK Fashion Partners',       'UK',          'trade@ukfashion.co.uk',     '+44-20-7946-0958',  4.30, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-008', 'Korean Beauty Group',       'South Korea', 'b2b@kbeauty.kr',            '+82-2-555-1234',    4.70, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-009', 'Canadian Outdoors Corp',    'Canada',      'sales@canoutdoors.ca',      '+1-604-555-0200',   4.10, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-010', 'Italian Craft Foods',       'Italy',       'export@itcraftfoods.it',    '+39-02-1234567',    4.40, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-011', 'Mexican Textiles SA',       'Mexico',      'ventas@mextextiles.mx',     '+52-55-1234-5678',  3.80, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-012', 'Australian Gear Pty',       'Australia',   'orders@ausgear.com.au',     '+61-2-9876-5432',   4.20, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-013', 'Indian IT Hardware',        'India',       'sales@indhardware.in',      '+91-22-1234-5678',  3.70, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-014', 'French Luxury Goods',       'France',      'b2b@frenchluxury.fr',       '+33-1-2345-6789',   4.90, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-015', 'Spanish Olive Co',          'Spain',       'export@spanisholive.es',    '+34-91-123-4567',   4.00, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-016', 'Taiwan Semiconductor',      'Taiwan',      'sales@twsemi.tw',           '+886-2-1234-5678',  4.60, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-017', 'Dutch Logistics Parts',     'Netherlands', 'parts@dutchlog.nl',         '+31-20-1234567',    4.10, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-018', 'Polish Furniture Works',    'Poland',      'export@plfurniture.pl',     '+48-22-123-4567',   3.90, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-019', 'Turkish Apparel Group',     'Turkey',      'orders@turkapparel.tr',     '+90-212-123-4567',  3.60, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-020', 'Singapore Trading Hub',     'Singapore',   'trade@sgtrading.sg',        '+65-6123-4567',     4.50, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-021', 'Colombian Coffee Export',   'Colombia',    'export@coffee.co',          '+57-1-234-5678',    4.30, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-022', 'South African Mining Sup',  'South Africa','sales@saminsup.co.za',      '+27-11-123-4567',   3.50, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-023', 'Norwegian Seafood AS',      'Norway',      'orders@norseafood.no',      '+47-22-123456',     4.40, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-024', 'Belgian Chocolate NV',      'Belgium',     'b2b@bechocolate.be',        '+32-2-123-4567',    4.80, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-025', 'Thai Silk Exporters',       'Thailand',    'export@thaisilk.th',        '+66-2-123-4567',    4.00, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-026', 'Irish Dairy Products',      'Ireland',     'sales@irdairy.ie',          '+353-1-123-4567',   4.20, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-027', 'Vietnam Manufacturing',     'Vietnam',     'factory@vnmfg.vn',          '+84-28-1234-5678',  3.80, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-028', 'Chilean Wine Distributors', 'Chile',       'export@clwine.cl',          '+56-2-1234-5678',   4.50, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-029', 'Egyptian Cotton Mills',     'Egypt',       'orders@egcotton.eg',        '+20-2-1234-5678',   3.70, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-030', 'Peruvian Alpaca Textiles',  'Peru',        'export@alpaca.pe',          '+51-1-123-4567',    4.10, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-031', 'Moroccan Argan Oil Co',     'Morocco',     'sales@arganoil.ma',         '+212-5-1234-5678',  4.00, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-032', 'Indonesian Furniture',      'Indonesia',   'export@idfurniture.id',     '+62-21-1234-5678',  3.60, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-033', 'Greek Olive Oil SA',        'Greece',      'b2b@grkolive.gr',           '+30-210-1234567',   4.30, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-034', 'Czech Glass Works',         'Czechia',     'export@czglass.cz',         '+420-2-1234-5678',  4.10, 1);
INSERT INTO suppliers (supplier_code, supplier_name, country, contact_email, contact_phone, rating, is_active) VALUES ('SUP-035', 'Inactive Supplier LLC',     'USA',         NULL,                        NULL,                NULL, 0);

-- Employees (75) with manager hierarchy; IDs auto-assigned 1..75 in this order
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-001', 'Margaret', 'Chen',      'margaret.chen@retail.com',      1, NULL, DATE '2015-03-15', 125000.00, NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-002', 'James',    'Wilson',    'james.wilson@retail.com',       2, NULL, DATE '2014-06-01', 118000.00, NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-003', 'Sarah',    'Kim',       'sarah.kim@retail.com',          3, NULL, DATE '2016-01-10', 132000.00, NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-004', 'Robert',   'Martinez',  'robert.martinez@retail.com',    4, NULL, DATE '2013-09-20', 98000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-005', 'Emily',    'Johnson',   'emily.johnson@retail.com',      5, NULL, DATE '2017-04-05', 95000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-006', 'David',    'Brown',     'david.brown@retail.com',        6, NULL, DATE '2016-08-12', 105000.00, NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-007', 'Lisa',     'Anderson',  'lisa.anderson@retail.com',      7, NULL, DATE '2015-11-30', 102000.00, NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-008', 'Michael',  'Taylor',    'michael.taylor@retail.com',     8, NULL, DATE '2018-02-14', 88000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-009', 'Jennifer', 'Lee',       'jennifer.lee@retail.com',       1, 1,    DATE '2017-07-01', 85000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-010', 'William',  'Davis',     'william.davis@retail.com',      2, 2,    DATE '2018-03-20', 72000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-011', 'Amanda',   'Garcia',    'amanda.garcia@retail.com',      2, 2,    DATE '2019-01-15', 68000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-012', 'Christopher', 'Miller', 'christopher.miller@retail.com', 2, 2,    DATE '2019-06-10', 71000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-013', 'Jessica',  'Rodriguez', 'jessica.rodriguez@retail.com',  2, 10,   DATE '2020-02-01', 55000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-014', 'Daniel',   'Martins',   'daniel.martins@retail.com',     2, 10,   DATE '2020-08-15', 52000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-015', 'Ashley',   'Thompson',  'ashley.thompson@retail.com',    2, 11,   DATE '2021-01-20', 48000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-016', 'Matthew',  'White',     'matthew.white@retail.com',      2, 11,   DATE '2021-05-10', 49000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-017', 'Nicole',   'Harris',    'nicole.harris@retail.com',      2, 12,   DATE '2021-09-01', 47000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-018', 'Andrew',   'Clark',     'andrew.clark@retail.com',       2, 12,   DATE '2022-03-15', 46000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-019', 'Stephanie','Lewis',     'stephanie.lewis@retail.com',    2, 10,   DATE '2022-07-01', 45000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-020', 'Joshua',   'Walker',    'joshua.walker@retail.com',      2, 11,   DATE '2023-01-10', 44000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-021', 'Brian',    'Hall',      'brian.hall@retail.com',         3, 3,    DATE '2018-05-01', 95000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-022', 'Melissa',  'Allen',     'melissa.allen@retail.com',      3, 3,    DATE '2019-03-15', 88000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-023', 'Kevin',    'Young',     'kevin.young@retail.com',        3, 21,   DATE '2020-06-01', 78000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-024', 'Rachel',   'King',      'rachel.king@retail.com',        3, 21,   DATE '2021-02-20', 72000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-025', 'Ryan',     'Wright',    'ryan.wright@retail.com',        3, 22,   DATE '2021-08-10', 70000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-026', 'Laura',    'Scott',     'laura.scott@retail.com',        3, 22,   DATE '2022-04-01', 68000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-027', 'Jason',    'Green',     'jason.green@retail.com',        3, 23,   DATE '2022-10-15', 65000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-028', 'Heather',  'Adams',     'heather.adams@retail.com',      3, 23,   DATE '2023-03-01', 62000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-029', 'Justin',   'Baker',     'justin.baker@retail.com',       4, 4,    DATE '2019-01-05', 62000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-030', 'Samantha', 'Nelson',    'samantha.nelson@retail.com',    4, 4,    DATE '2019-07-20', 58000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-031', 'Brandon',  'Carter',    'brandon.carter@retail.com',     4, 29,   DATE '2020-11-10', 52000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-032', 'Megan',    'Mitchell',  'megan.mitchell@retail.com',     4, 29,   DATE '2021-04-15', 50000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-033', 'Tyler',    'Perez',     'tyler.perez@retail.com',        4, 30,   DATE '2021-12-01', 48000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-034', 'Angela',   'Roberts',   'angela.roberts@retail.com',     4, 30,   DATE '2022-06-20', 47000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-035', 'Eric',     'Turner',    'eric.turner@retail.com',        4, 29,   DATE '2023-02-01', 46000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-036', 'Christina','Phillips',  'christina.phillips@retail.com', 5, 5,    DATE '2018-09-01', 72000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-037', 'Adam',     'Campbell',  'adam.campbell@retail.com',      5, 5,    DATE '2019-11-15', 65000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-038', 'Rebecca',  'Parker',    'rebecca.parker@retail.com',     5, 36,   DATE '2020-05-20', 58000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-039', 'Nathan',   'Evans',     'nathan.evans@retail.com',       5, 36,   DATE '2021-01-10', 55000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-040', 'Michelle', 'Edwards',   'michelle.edwards@retail.com',   5, 37,   DATE '2021-07-01', 52000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-041', 'Patrick',  'Collins',   'patrick.collins@retail.com',    6, 6,    DATE '2019-02-01', 78000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-042', 'Kimberly', 'Stewart',   'kimberly.stewart@retail.com',   6, 6,    DATE '2019-10-15', 72000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-043', 'Steven',   'Sanchez',   'steven.sanchez@retail.com',     6, 41,   DATE '2020-08-01', 65000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-044', 'Amy',      'Morris',    'amy.morris@retail.com',         6, 41,   DATE '2021-03-20', 62000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-045', 'Timothy',  'Rogers',    'timothy.rogers@retail.com',     6, 42,   DATE '2021-11-10', 58000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-046', 'Angela',   'Reed',      'angela.reed@retail.com',        6, 42,   DATE '2022-05-01', 56000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-047', 'Gregory',  'Cook',      'gregory.cook@retail.com',       7, 7,    DATE '2018-04-10', 82000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-048', 'Sandra',   'Morgan',    'sandra.morgan@retail.com',      7, 7,    DATE '2019-06-15', 75000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-049', 'Kenneth',  'Bell',      'kenneth.bell@retail.com',       7, 47,   DATE '2020-02-20', 68000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-050', 'Donna',    'Murphy',    'donna.murphy@retail.com',       7, 47,   DATE '2020-10-01', 65000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-051', 'Paul',     'Bailey',    'paul.bailey@retail.com',        7, 48,   DATE '2021-06-15', 60000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-052', 'Carol',    'Rivera',    'carol.rivera@retail.com',       7, 48,   DATE '2022-01-20', 58000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-053', 'Mark',     'Cooper',    'mark.cooper@retail.com',        8, 8,    DATE '2019-05-01', 70000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-054', 'Ruth',     'Richardson','ruth.richardson@retail.com',    8, 8,    DATE '2020-01-15', 65000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-055', 'George',   'Cox',       'george.cox@retail.com',         8, 53,   DATE '2021-04-01', 58000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-056', 'Sharon',   'Howard',    'sharon.howard@retail.com',      8, 53,   DATE '2021-10-20', 55000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-057', 'Edward',   'Ward',      'edward.ward@retail.com',        8, 54,   DATE '2022-07-10', 52000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-058', 'Cynthia',  'Torres',    'cynthia.torres@retail.com',     8, 54,   DATE '2023-01-05', 50000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-059', 'Frank',    'Peterson',  'frank.peterson@retail.com',     1, 9,    DATE '2020-03-01', 72000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-060', 'Deborah',  'Gray',      'deborah.gray@retail.com',       1, 9,    DATE '2020-09-15', 68000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-061', 'Raymond',  'Ramirez',   'raymond.ramirez@retail.com',    1, 9,    DATE '2021-05-01', 65000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-062', 'Janet',    'James',     'janet.james@retail.com',        1, 9,    DATE '2022-02-10', 62000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-063', 'Scott',    'Watson',    'scott.watson@retail.com',       2, 10,   DATE '2019-04-01', 58000.00,  DATE '2024-06-30');
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-064', 'Maria',    'Brooks',    'maria.brooks@retail.com',       2, 11,   DATE '2019-08-15', 56000.00,  DATE '2024-03-15');
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-065', 'Gary',     'Kelly',     'gary.kelly@retail.com',         3, 21,   DATE '2020-01-10', NULL,      NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-066', 'Betty',    'Sanders',   'betty.sanders@retail.com',      3, 22,   DATE '2020-07-01', NULL,      NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-067', 'Larry',    'Price',     'larry.price@retail.com',        4, 29,   DATE '2021-02-15', NULL,      NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-068', 'Dorothy',  'Bennett',   'dorothy.bennett@retail.com',    5, 36,   DATE '2021-09-01', NULL,      NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-069', 'Jerry',    'Wood',      'jerry.wood@retail.com',         6, 41,   DATE '2022-04-10', NULL,      NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-070', 'Karen',    'Barnes',    'karen.barnes@retail.com',       7, 47,   DATE '2022-11-01', NULL,      NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-071', 'Dennis',   'Ross',      'dennis.ross@retail.com',        8, 53,   DATE '2023-05-15', NULL,      NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-072', 'Nancy',    'Henderson', 'nancy.henderson@retail.com',    2, 12,   DATE '2023-08-01', 42000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-073', 'Peter',    'Coleman',   'peter.coleman@retail.com',      2, 12,   DATE '2024-01-15', 41000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-074', 'Helen',    'Jenkins',   'helen.jenkins@retail.com',      2, 10,   DATE '2024-06-01', 40000.00,  NULL);
INSERT INTO employees (employee_number, first_name, last_name, email, department_id, manager_id, hire_date, salary, terminated_at) VALUES ('EMP-075', 'Carl',     'Perry',     'carl.perry@retail.com',         2, 11,   DATE '2024-09-10', 39000.00,  NULL);

COMMIT;

EXIT;
