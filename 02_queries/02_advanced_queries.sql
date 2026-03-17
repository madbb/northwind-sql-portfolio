-- =============================================================================
-- Northwind – Advanced Queries
-- =============================================================================
-- Themen: Multi-JOINs, Subqueries, CASE, Window Functions, Business Insights
-- =============================================================================

USE northwind;

-- -----------------------------------------------------------------------------
-- 1. Top 10 Kunden nach Gesamtumsatz
-- -----------------------------------------------------------------------------
SELECT
    c.customerID,
    c.companyName,
    c.country,
    ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS gesamtUmsatz
FROM customers c
JOIN orders     o  ON c.customerID = o.customerID
JOIN order_details od ON o.orderID = od.orderID
GROUP BY c.customerID, c.companyName, c.country
ORDER BY gesamtUmsatz DESC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- 2. Umsatz pro Monat (Zeitreihe)
-- -----------------------------------------------------------------------------
SELECT
    YEAR(o.orderDate)                                              AS jahr,
    MONTH(o.orderDate)                                             AS monat,
    COUNT(DISTINCT o.orderID)                                      AS anzahlBestellungen,
    ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2)  AS umsatz
FROM orders o
JOIN order_details od ON o.orderID = od.orderID
GROUP BY jahr, monat
ORDER BY jahr, monat;

-- -----------------------------------------------------------------------------
-- 3. Beste Produkte nach Umsatz
-- -----------------------------------------------------------------------------
SELECT
    p.productName,
    c.categoryName,
    SUM(od.quantity)                                                AS verkaufteMenge,
    ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2)  AS gesamtUmsatz
FROM products p
JOIN categories    c  ON p.categoryID  = c.categoryID
JOIN order_details od ON p.productID   = od.productID
GROUP BY p.productID, p.productName, c.categoryName
ORDER BY gesamtUmsatz DESC
LIMIT 15;

-- -----------------------------------------------------------------------------
-- 4. Mitarbeiter-Performance: Umsatz & Bestellanzahl
-- -----------------------------------------------------------------------------
SELECT
    e.employeeName,
    e.title,
    COUNT(DISTINCT o.orderID)                                       AS anzahlBestellungen,
    ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2)  AS gesamtUmsatz,
    ROUND(AVG(od.unitPrice * od.quantity * (1 - od.discount)), 2)  AS avgProPosition
FROM employees e
JOIN orders        o  ON e.employeeID = o.employeeID
JOIN order_details od ON o.orderID    = od.orderID
GROUP BY e.employeeID, e.employeeName, e.title
ORDER BY gesamtUmsatz DESC;

-- -----------------------------------------------------------------------------
-- 5. Kunden ohne Bestellung (LEFT JOIN + NULL-Check)
-- -----------------------------------------------------------------------------
SELECT
    c.customerID,
    c.companyName,
    c.country
FROM customers c
LEFT JOIN orders o ON c.customerID = o.customerID
WHERE o.orderID IS NULL
ORDER BY c.country, c.companyName;

-- -----------------------------------------------------------------------------
-- 6. Lieferverzögerung pro Versandunternehmen
--    (Tage zwischen Bestelldatum und Versanddatum)
-- -----------------------------------------------------------------------------
SELECT
    s.companyName                             AS versandUnternehmen,
    COUNT(o.orderID)                          AS anzahlLieferungen,
    ROUND(AVG(DATEDIFF(o.shippedDate, o.orderDate)), 1) AS avgLieferTage,
    MAX(DATEDIFF(o.shippedDate, o.orderDate)) AS maxLieferTage
FROM shippers s
JOIN orders o ON s.shipperID = o.shipperID
WHERE o.shippedDate IS NOT NULL
GROUP BY s.shipperID, s.companyName
ORDER BY avgLieferTage;

-- -----------------------------------------------------------------------------
-- 7. Produkte, die nie bestellt wurden (Subquery)
-- -----------------------------------------------------------------------------
SELECT
    productID,
    productName,
    unitPrice
FROM products
WHERE productID NOT IN (
    SELECT DISTINCT productID FROM order_details
)
ORDER BY productName;

-- -----------------------------------------------------------------------------
-- 8. ABC-Analyse: Kunden in Umsatz-Segmente einteilen (CASE)
-- -----------------------------------------------------------------------------
SELECT
    segment,
    COUNT(*)                     AS anzahlKunden,
    ROUND(SUM(gesamtUmsatz), 2)  AS umsatzSegment
FROM (
    SELECT
        c.customerID,
        c.companyName,
        ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS gesamtUmsatz,
        CASE
            WHEN SUM(od.unitPrice * od.quantity * (1 - od.discount)) >= 10000 THEN 'A – Top'
            WHEN SUM(od.unitPrice * od.quantity * (1 - od.discount)) >= 5000  THEN 'B – Mittel'
            ELSE 'C – Gering'
        END AS segment
    FROM customers c
    JOIN orders        o  ON c.customerID = o.customerID
    JOIN order_details od ON o.orderID    = od.orderID
    GROUP BY c.customerID, c.companyName
) AS kundenUmsatz
GROUP BY segment
ORDER BY segment;
