-- =============================================================================
-- Northwind – Basic Queries
-- =============================================================================
-- Themen: SELECT, WHERE, ORDER BY, GROUP BY, HAVING, Aggregatfunktionen
-- =============================================================================

USE northwind;

-- -----------------------------------------------------------------------------
-- 1. Alle Kunden aus Deutschland
-- -----------------------------------------------------------------------------
SELECT
    customerID,
    companyName,
    contactName,
    city
FROM customers
WHERE country = 'Germany'
ORDER BY city;

-- -----------------------------------------------------------------------------
-- 2. Produkte unter 20€, nicht eingestellt, sortiert nach Preis
-- -----------------------------------------------------------------------------
SELECT
    productName,
    unitPrice,
    quantityPerUnit
FROM products
WHERE unitPrice < 20
  AND discontinued = 0
ORDER BY unitPrice DESC;

-- -----------------------------------------------------------------------------
-- 3. Anzahl Kunden pro Land
-- -----------------------------------------------------------------------------
SELECT
    country,
    COUNT(*) AS anzahlKunden
FROM customers
GROUP BY country
ORDER BY anzahlKunden DESC;

-- -----------------------------------------------------------------------------
-- 4. Länder mit mehr als 5 Kunden (HAVING)
-- -----------------------------------------------------------------------------
SELECT
    country,
    COUNT(*) AS anzahlKunden
FROM customers
GROUP BY country
HAVING anzahlKunden > 5
ORDER BY anzahlKunden DESC;

-- -----------------------------------------------------------------------------
-- 5. Umsatz pro Bestellung (ohne Rabatt)
-- -----------------------------------------------------------------------------
SELECT
    orderID,
    SUM(unitPrice * quantity)                   AS umsatzBrutto,
    ROUND(SUM(unitPrice * quantity * (1 - discount)), 2) AS umsatzNachRabatt
FROM order_details
GROUP BY orderID
ORDER BY umsatzNachRabatt DESC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- 6. Durchschnittspreis pro Kategorie
-- -----------------------------------------------------------------------------
SELECT
    c.categoryName,
    COUNT(p.productID)      AS anzahlProdukte,
    ROUND(AVG(p.unitPrice), 2) AS durchschnittsPreis,
    MIN(p.unitPrice)        AS guenstigstes,
    MAX(p.unitPrice)        AS teuerstes
FROM categories c
JOIN products p ON c.categoryID = p.categoryID
GROUP BY c.categoryName
ORDER BY durchschnittsPreis DESC;

-- -----------------------------------------------------------------------------
-- 7. Bestellungen im Jahr 2014
-- -----------------------------------------------------------------------------
SELECT
    orderID,
    customerID,
    orderDate,
    shippedDate,
    freight
FROM orders
WHERE YEAR(orderDate) = 2014
ORDER BY orderDate;

-- -----------------------------------------------------------------------------
-- 8. Mitarbeiter und ihr Vorgesetzter (Self-JOIN)
-- -----------------------------------------------------------------------------
SELECT
    e.employeeName                          AS mitarbeiter,
    e.title                                 AS position,
    COALESCE(m.employeeName, '– Kein –')    AS vorgesetzter
FROM employees e
LEFT JOIN employees m ON e.reportsTo = m.employeeID
ORDER BY vorgesetzter, mitarbeiter;
