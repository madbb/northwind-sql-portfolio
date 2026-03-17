-- =============================================================================
-- Northwind – DML Basics
-- =============================================================================
-- Themen: INSERT, UPDATE, DELETE in praxisnahen Geschäftsszenarien
-- Schwierigkeit: ⭐ bis ⭐⭐⭐
-- =============================================================================

USE northwind;

-- =============================================================================
-- INSERT – Neue Datensätze anlegen
-- =============================================================================

-- ⭐ 1. Neuen Kunden anlegen
INSERT INTO customers (customerID, companyName, contactName, contactTitle, city, country)
VALUES ('DGMBH', 'Dortmund GmbH', 'Marcel Weber', 'Sales Manager', 'Dortmund', 'Germany');

-- ⭐ 2. Mehrere Kunden auf einmal (Multi-Row INSERT)
INSERT INTO customers (customerID, companyName, contactName, city, country)
VALUES
    ('BRLNR', 'Berliner AG',     'Anna Schmidt',  'Berlin',   'Germany'),
    ('MCHNR', 'Münchner GmbH',   'Klaus Bauer',   'München',  'Germany'),
    ('HMBGR', 'Hamburger Corp',  'Lisa Fischer',  'Hamburg',  'Germany');

-- ⭐⭐ 3. Neue Bestellung für bestehenden Kunden anlegen
INSERT INTO orders (customerID, employeeID, orderDate, requiredDate, shipperID, freight)
VALUES ('DGMBH', 3, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 1, 12.50);

-- ⭐⭐ 4. Bestellposition zur neuen Bestellung hinzufügen
--    (LAST_INSERT_ID() holt die zuletzt generierte orderID)
INSERT INTO order_details (orderID, productID, unitPrice, quantity, discount)
VALUES
    (LAST_INSERT_ID(), 1,  18.00, 5, 0.0),
    (LAST_INSERT_ID(), 11, 21.00, 3, 0.1);

-- ⭐⭐⭐ 5. Neues Produkt in bestehende Kategorie einfügen
INSERT INTO products (productName, quantityPerUnit, unitPrice, discontinued, categoryID)
VALUES ('Dortmund Dark Roast', '12 - 250g bags', 14.99, 0,
        (SELECT categoryID FROM categories WHERE categoryName = 'Beverages'));


-- =============================================================================
-- UPDATE – Datensätze ändern
-- =============================================================================

-- ⭐ 6. Einzelnes Feld aktualisieren
UPDATE customers
SET contactTitle = 'Owner'
WHERE customerID = 'DGMBH';

-- ⭐ 7. Mehrere Felder gleichzeitig ändern
UPDATE products
SET unitPrice    = 15.99,
    discontinued = 0
WHERE productName = 'Dortmund Dark Roast';

-- ⭐⭐ 8. Alle Produkte einer Kategorie um 10% verteuern
UPDATE products p
JOIN categories c ON p.categoryID = c.categoryID
SET p.unitPrice = ROUND(p.unitPrice * 1.10, 2)
WHERE c.categoryName = 'Beverages'
  AND p.discontinued = 0;

-- ⭐⭐ 9. Frachtkosten für verspätete Bestellungen nachträglich anpassen
--    (Bestellungen die mehr als 30 Tage zur Lieferung brauchten)
UPDATE orders
SET freight = freight * 0.5
WHERE shippedDate IS NOT NULL
  AND DATEDIFF(shippedDate, orderDate) > 30;

-- ⭐⭐⭐ 10. Mitarbeiter befördern – Titel aktualisieren basierend auf Umsatz
--     Mitarbeiter mit über 100.000€ Umsatz bekommen den Titel 'Senior Sales Representative'
UPDATE employees e
JOIN (
    SELECT o.employeeID,
           ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS gesamtUmsatz
    FROM orders o
    JOIN order_details od ON o.orderID = od.orderID
    GROUP BY o.employeeID
) AS umsatz ON e.employeeID = umsatz.employeeID
SET e.title = 'Senior Sales Representative'
WHERE umsatz.gesamtUmsatz > 100000
  AND e.title = 'Sales Representative';


-- =============================================================================
-- DELETE – Datensätze löschen
-- =============================================================================

-- ⭐ 11. Einzelnen Kunden löschen (nur wenn keine Bestellungen vorhanden)
DELETE FROM customers
WHERE customerID = 'HMBGR';

-- ⭐⭐ 12. Alle Testkunden löschen (Muster im Namen)
DELETE FROM customers
WHERE companyName LIKE '%Test%'
   OR companyName LIKE '%Demo%';

-- ⭐⭐ 13. Eingestellte Produkte ohne Bestellhistorie entfernen
DELETE FROM products
WHERE discontinued = 1
  AND productID NOT IN (
      SELECT DISTINCT productID FROM order_details
  );

-- ⭐⭐⭐ 14. Aufräumen: Demo-Daten aus dieser Übung entfernen
--     Reihenfolge beachten: erst abhängige Tabellen, dann Elterntabellen
DELETE od FROM order_details od
JOIN orders o ON od.orderID = o.orderID
WHERE o.customerID = 'DGMBH';

DELETE FROM orders    WHERE customerID IN ('DGMBH', 'BRLNR', 'MCHNR');
DELETE FROM customers WHERE customerID IN ('DGMBH', 'BRLNR', 'MCHNR');
DELETE FROM products  WHERE productName = 'Dortmund Dark Roast';
