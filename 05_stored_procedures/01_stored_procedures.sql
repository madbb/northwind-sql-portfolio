-- =============================================================================
-- Northwind – Stored Procedures
-- =============================================================================
-- Gespeicherte Prozeduren für wiederkehrende Geschäftslogik
-- =============================================================================

USE northwind;

DELIMITER $$

-- -----------------------------------------------------------------------------
-- Procedure 1: Kunden nach Land abrufen
-- Parameter: p_country VARCHAR(50)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_GetCustomersByCountry(
    IN p_country VARCHAR(50)
)
BEGIN
    SELECT
        customerID,
        companyName,
        contactName,
        city
    FROM customers
    WHERE country = p_country
    ORDER BY city, companyName;
END$$

-- Aufruf: CALL sp_GetCustomersByCountry('Germany');

-- -----------------------------------------------------------------------------
-- Procedure 2: Top-N Produkte nach Umsatz
-- Parameter: p_limit INT (Anzahl der Ergebnisse)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_TopProductsByRevenue(
    IN p_limit INT
)
BEGIN
    SELECT
        p.productName,
        c.categoryName,
        SUM(od.quantity)                                               AS verkaufteMenge,
        ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS gesamtUmsatz
    FROM products p
    JOIN categories    c  ON p.categoryID  = c.categoryID
    JOIN order_details od ON p.productID   = od.productID
    GROUP BY p.productID, p.productName, c.categoryName
    ORDER BY gesamtUmsatz DESC
    LIMIT p_limit;
END$$

-- Aufruf: CALL sp_TopProductsByRevenue(10);

-- -----------------------------------------------------------------------------
-- Procedure 3: Neue Bestellung anlegen (mit Fehlerbehandlung)
-- Legt einen neuen Eintrag in orders an und gibt die neue orderID zurück
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_CreateOrder(
    IN  p_customerID  CHAR(5),
    IN  p_employeeID  INT,
    IN  p_shipperID   INT,
    IN  p_freight     DECIMAL(10,2),
    OUT p_newOrderID  INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_newOrderID = -1;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO orders (customerID, employeeID, orderDate, shipperID, freight)
    VALUES (p_customerID, p_employeeID, CURDATE(), p_shipperID, p_freight);

    SET p_newOrderID = LAST_INSERT_ID();

    COMMIT;
END$$

-- Aufruf:
-- CALL sp_CreateOrder('ALFKI', 1, 2, 15.50, @newID);
-- SELECT @newID;

-- -----------------------------------------------------------------------------
-- Procedure 4: Umsatz-Report für einen Zeitraum
-- Parameter: p_start DATE, p_end DATE
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_RevenueReport(
    IN p_start DATE,
    IN p_end   DATE
)
BEGIN
    SELECT
        YEAR(o.orderDate)                                              AS jahr,
        MONTH(o.orderDate)                                             AS monat,
        COUNT(DISTINCT o.orderID)                                      AS anzahlBestellungen,
        ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS umsatz
    FROM orders o
    JOIN order_details od ON o.orderID = od.orderID
    WHERE o.orderDate BETWEEN p_start AND p_end
    GROUP BY jahr, monat
    ORDER BY jahr, monat;
END$$

-- Aufruf: CALL sp_RevenueReport('2014-01-01', '2014-12-31');

DELIMITER ;
