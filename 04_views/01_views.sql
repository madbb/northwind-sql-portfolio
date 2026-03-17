-- =============================================================================
-- Northwind – Views
-- =============================================================================
-- Views kapseln komplexe Abfragen als wiederverwendbare "virtuelle Tabellen"
-- =============================================================================

USE northwind;

-- -----------------------------------------------------------------------------
-- View 1: Vollständige Bestellübersicht
-- Kombiniert orders, customers, employees und shippers in einer Ansicht
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_orders_full AS
SELECT
    o.orderID,
    o.orderDate,
    o.shippedDate,
    o.freight,
    c.companyName   AS kunde,
    c.country       AS kundenLand,
    e.employeeName  AS mitarbeiter,
    s.companyName   AS versandUnternehmen
FROM orders o
LEFT JOIN customers c ON o.customerID = o.customerID
LEFT JOIN employees e ON o.employeeID = e.employeeID
LEFT JOIN shippers  s ON o.shipperID  = s.shipperID;

-- Verwendung:
-- SELECT * FROM vw_orders_full WHERE kundenLand = 'Germany';

-- -----------------------------------------------------------------------------
-- View 2: Produkt-Katalog mit Kategorie
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_products_catalog AS
SELECT
    p.productID,
    p.productName,
    p.unitPrice,
    p.quantityPerUnit,
    p.discontinued,
    c.categoryName,
    c.description AS kategoriBeschreibung
FROM products p
JOIN categories c ON p.categoryID = c.categoryID;

-- Verwendung:
-- SELECT * FROM vw_products_catalog WHERE categoryName = 'Beverages' AND discontinued = 0;

-- -----------------------------------------------------------------------------
-- View 3: Umsatz pro Kunde (aggregiert)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_customer_revenue AS
SELECT
    c.customerID,
    c.companyName,
    c.country,
    COUNT(DISTINCT o.orderID)                                       AS anzahlBestellungen,
    ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2)  AS gesamtUmsatz,
    ROUND(AVG(od.unitPrice * od.quantity * (1 - od.discount)), 2)  AS avgProPosition
FROM customers c
JOIN orders        o  ON c.customerID = o.customerID
JOIN order_details od ON o.orderID    = od.orderID
GROUP BY c.customerID, c.companyName, c.country;

-- Verwendung:
-- SELECT * FROM vw_customer_revenue ORDER BY gesamtUmsatz DESC LIMIT 10;

-- -----------------------------------------------------------------------------
-- View 4: Monatlicher Umsatz-Report
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    YEAR(o.orderDate)                                               AS jahr,
    MONTH(o.orderDate)                                              AS monat,
    COUNT(DISTINCT o.orderID)                                       AS anzahlBestellungen,
    ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2)  AS umsatz
FROM orders o
JOIN order_details od ON o.orderID = od.orderID
WHERE o.orderDate IS NOT NULL
GROUP BY jahr, monat;

-- Verwendung:
-- SELECT * FROM vw_monthly_revenue WHERE jahr = 2014 ORDER BY monat;
