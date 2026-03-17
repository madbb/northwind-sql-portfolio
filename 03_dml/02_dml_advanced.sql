-- =============================================================================
-- Northwind – DML Advanced
-- =============================================================================
-- Themen: UPSERT, CASE in UPDATE, Bulk-Operationen, CASCADE-Verhalten
-- Schwierigkeit: ⭐⭐⭐ bis ⭐⭐⭐⭐
-- =============================================================================

USE northwind;

-- =============================================================================
-- UPSERT – INSERT ... ON DUPLICATE KEY UPDATE
-- =============================================================================
-- Logik: Existiert der Datensatz bereits → UPDATE, sonst → INSERT
-- Typischer Anwendungsfall: Lagerbestände, Preislisten synchronisieren

-- ⭐⭐⭐ 1. Produktpreis aktualisieren oder neues Produkt anlegen
INSERT INTO products (productID, productName, unitPrice, discontinued, categoryID)
VALUES (1, 'Chai', 20.00, 0, 1)
ON DUPLICATE KEY UPDATE
    unitPrice = VALUES(unitPrice);
-- Ergebnis: Produkt 1 existiert bereits → nur unitPrice wird auf 20.00 gesetzt

-- ⭐⭐⭐ 2. Kunden anlegen oder Kontaktname aktualisieren
INSERT INTO customers (customerID, companyName, contactName, city, country)
VALUES ('ALFKI', 'Alfreds Futterkiste', 'Neuer Kontakt', 'Berlin', 'Germany')
ON DUPLICATE KEY UPDATE
    contactName = VALUES(contactName);
-- Ergebnis: ALFKI existiert bereits → nur contactName wird aktualisiert


-- =============================================================================
-- CASE in UPDATE – Bedingte Aktualisierungen
-- =============================================================================

-- ⭐⭐⭐ 3. Rabattstrategie: Frachtkosten nach Bestellgröße anpassen
--    Bestellungen mit hohem Umsatz bekommen reduzierten Frachtpreis
UPDATE orders o
JOIN (
    SELECT orderID,
           SUM(unitPrice * quantity * (1 - discount)) AS bestellWert
    FROM order_details
    GROUP BY orderID
) AS bw ON o.orderID = bw.orderID
SET o.freight = CASE
    WHEN bw.bestellWert >= 2000 THEN ROUND(o.freight * 0.50, 2)  -- 50% Rabatt
    WHEN bw.bestellWert >= 1000 THEN ROUND(o.freight * 0.75, 2)  -- 25% Rabatt
    WHEN bw.bestellWert >= 500  THEN ROUND(o.freight * 0.90, 2)  -- 10% Rabatt
    ELSE o.freight                                                 -- kein Rabatt
END;

-- ⭐⭐⭐ 4. Produktstatus basierend auf Verkaufszahlen setzen
--    Produkte mit 0 Verkäufen werden auf discontinued = 1 gesetzt
UPDATE products p
LEFT JOIN order_details od ON p.productID = od.productID
SET p.discontinued = CASE
    WHEN od.productID IS NULL THEN 1   -- nie bestellt → einstellen
    ELSE p.discontinued                -- sonst unverändert
END;


-- =============================================================================
-- Bulk-Operationen – Mehrere Tabellen koordiniert bearbeiten
-- =============================================================================

-- ⭐⭐⭐⭐ 5. Kompletten Kunden mit allen Bestellungen "archivieren"
--    Simulation: Kundenstatus auf inaktiv setzen + Bestellungen sperren
--    (In echter DB: Archivtabellen; hier als UPDATE demonstriert)

-- Schritt 1: Kunden markieren
UPDATE customers
SET contactTitle = CONCAT('[INAKTIV] ', contactTitle)
WHERE country = 'Germany'
  AND customerID NOT IN (
      SELECT DISTINCT customerID FROM orders
      WHERE YEAR(orderDate) >= 2015
  );

-- Schritt 2: Rückgängig machen (Aufräumen)
UPDATE customers
SET contactTitle = REPLACE(contactTitle, '[INAKTIV] ', '')
WHERE contactTitle LIKE '[INAKTIV]%';


-- =============================================================================
-- CASCADE-Verhalten verstehen
-- =============================================================================

-- ⭐⭐⭐⭐ 6. Demonstration: ON DELETE CASCADE
--    Wenn eine Bestellung gelöscht wird, werden automatisch
--    alle zugehörigen order_details mitgelöscht (CASCADE ist im Schema definiert)

-- Testdaten anlegen
INSERT INTO customers (customerID, companyName, city, country)
VALUES ('CASC1', 'Cascade Test GmbH', 'Berlin', 'Germany');

INSERT INTO orders (customerID, employeeID, orderDate, shipperID, freight)
VALUES ('CASC1', 1, CURDATE(), 1, 5.00);

SET @testOrderID = LAST_INSERT_ID();

INSERT INTO order_details (orderID, productID, unitPrice, quantity, discount)
VALUES (@testOrderID, 1, 18.00, 2, 0),
       (@testOrderID, 2, 19.00, 1, 0);

-- Vor dem Löschen: Wie viele Positionen?
SELECT COUNT(*) AS positionenVorher FROM order_details WHERE orderID = @testOrderID;

-- Bestellung löschen → order_details werden automatisch mitgelöscht (ON DELETE CASCADE)
DELETE FROM orders WHERE orderID = @testOrderID;

-- Nach dem Löschen: Positionen sollten weg sein
SELECT COUNT(*) AS positionenNachher FROM order_details WHERE orderID = @testOrderID;

-- Aufräumen
DELETE FROM customers WHERE customerID = 'CASC1';


-- =============================================================================
-- CONCAT & YEAR() in DML – Praxisbeispiele
-- =============================================================================

-- ⭐⭐⭐ 7. Mitarbeiternamen formatieren (Nachname, Vorname → Vorname Nachname)
--    employeeName ist bereits "Vorname Nachname", hier als Transformations-Demo
UPDATE employees
SET employeeName = CONCAT(
    SUBSTRING_INDEX(employeeName, ' ', -1), ', ',   -- Nachname
    SUBSTRING_INDEX(employeeName, ' ', 1)            -- Vorname
)
WHERE employeeID = 1;

-- Rückgängig machen
UPDATE employees
SET employeeName = CONCAT(
    SUBSTRING_INDEX(employeeName, ' ', -1), ' ',
    SUBSTRING_INDEX(employeeName, ', ', 1)
)
WHERE employeeID = 1;
