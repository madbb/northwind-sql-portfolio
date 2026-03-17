-- =============================================================================
-- Northwind – CSV Import
-- =============================================================================
-- Voraussetzung: Schema aus 01_schema.sql muss bereits ausgeführt sein.
--
-- WICHTIG: Passe den Pfad zu den CSV-Dateien an dein System an:
--   Windows:  'C:/Users/DeinName/northwind-sql-portfolio/data/categories.csv'
--   Linux/Mac: '/home/deinname/northwind-sql-portfolio/data/categories.csv'
--
-- Falls Fehler 1292 (falsche Datumswerte) auftritt:
--   SET sql_mode = '';
-- =============================================================================

USE northwind;

-- Leerzeichen / falsche Datumswerte tolerieren
SET sql_mode = '';

-- -----------------------------------------------------------------------------
-- Reihenfolge: erst unabhängige Tabellen, dann abhängige (FK-Ketten beachten!)
-- -----------------------------------------------------------------------------

-- 1. Kategorien (keine FK)
LOAD DATA LOCAL INFILE 'data/categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(categoryID, categoryName, description);

-- 2. Versandunternehmen (keine FK)
LOAD DATA LOCAL INFILE 'data/shippers.csv'
INTO TABLE shippers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(shipperID, companyName);

-- 3. Kunden (keine FK)
LOAD DATA LOCAL INFILE 'data/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customerID, companyName, contactName, contactTitle, city, country);

-- 4. Mitarbeiter (FK: reportsTo -> employees, daher NULL-Handling notwendig)
LOAD DATA LOCAL INFILE 'data/employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(employeeID, employeeName, title, city, country, @reportsTo)
SET reportsTo = NULLIF(@reportsTo, '');

-- 5. Produkte (FK: categoryID)
LOAD DATA LOCAL INFILE 'data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(productID, productName, quantityPerUnit, unitPrice, discontinued, categoryID);

-- 6. Bestellungen (FK: customerID, employeeID, shipperID)
LOAD DATA LOCAL INFILE 'data/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(orderID, customerID, employeeID, orderDate, requiredDate,
 @shippedDate, shipperID, freight)
SET shippedDate = NULLIF(@shippedDate, '');

-- 7. Bestellpositionen (FK: orderID, productID)
LOAD DATA LOCAL INFILE 'data/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(orderID, productID, unitPrice, quantity, discount);

-- -----------------------------------------------------------------------------
-- Schnell-Check: Zeilenzahlen
-- -----------------------------------------------------------------------------
SELECT 'categories'    AS Tabelle, COUNT(*) AS Zeilen FROM categories   UNION ALL
SELECT 'shippers',                  COUNT(*)           FROM shippers      UNION ALL
SELECT 'customers',                 COUNT(*)           FROM customers     UNION ALL
SELECT 'employees',                 COUNT(*)           FROM employees     UNION ALL
SELECT 'products',                  COUNT(*)           FROM products      UNION ALL
SELECT 'orders',                    COUNT(*)           FROM orders        UNION ALL
SELECT 'order_details',             COUNT(*)           FROM order_details;

-- Erwartete Ergebnisse:
-- categories:    8
-- shippers:      3
-- customers:    91
-- employees:     9
-- products:     77
-- orders:       830
-- order_details: 2155
