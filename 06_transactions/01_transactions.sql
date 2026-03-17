-- =============================================================================
-- Northwind – Transactions & ACID
-- =============================================================================
-- Demonstriert Transaktionen, ROLLBACK, COMMIT und Fehlerbehandlung
-- in praxisnahen Szenarien
-- =============================================================================

USE northwind;

-- =============================================================================
-- THEORIE-RECAP: ACID
-- =============================================================================
-- A – Atomicity:   Alles oder nichts. Kein halbes UPDATE.
-- C – Consistency: Die DB bleibt in einem gültigen Zustand.
-- I – Isolation:   Parallele Transaktionen sehen sich nicht.
-- D – Durability:  Nach COMMIT sind Daten dauerhaft gespeichert.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Beispiel 1: Erfolgreiche Transaktion
-- Neuen Kunden anlegen und sofort eine Bestellung erstellen
-- -----------------------------------------------------------------------------
START TRANSACTION;

    INSERT INTO customers (customerID, companyName, contactName, city, country)
    VALUES ('NEUKD', 'Neue GmbH', 'Max Muster', 'Dortmund', 'Germany');

    INSERT INTO orders (customerID, employeeID, orderDate, shipperID, freight)
    VALUES ('NEUKD', 1, CURDATE(), 1, 9.99);

COMMIT;
-- Beide Zeilen sind jetzt dauerhaft gespeichert.


-- -----------------------------------------------------------------------------
-- Beispiel 2: ROLLBACK bei Fehler (manuell)
-- Wenn die Bestellung nicht angelegt werden kann → alles rückgängig machen
-- -----------------------------------------------------------------------------
START TRANSACTION;

    INSERT INTO customers (customerID, companyName, contactName, city, country)
    VALUES ('TESTX', 'Test AG', 'Anna Test', 'Berlin', 'Germany');

    -- Simulierter Fehler: ungültige employeeID (9999 existiert nicht)
    INSERT INTO orders (customerID, employeeID, orderDate, shipperID, freight)
    VALUES ('TESTX', 9999, CURDATE(), 1, 5.00);

ROLLBACK;
-- Der Kunde 'TESTX' wurde NICHT gespeichert – Atomicity in Aktion.


-- -----------------------------------------------------------------------------
-- Beispiel 3: Transaktion in Stored Procedure mit automatischem Rollback
-- (DECLARE EXIT HANDLER = try/catch in SQL)
-- -----------------------------------------------------------------------------
DELIMITER $$

CREATE OR REPLACE PROCEDURE sp_TransferOrder(
    IN p_orderID     INT,
    IN p_newCustomer CHAR(5)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Fehler: Transaktion wurde zurückgerollt.' AS status;
    END;

    START TRANSACTION;

        -- Bestellung dem neuen Kunden zuweisen
        UPDATE orders
        SET customerID = p_newCustomer
        WHERE orderID = p_orderID;

        -- Sicherheitsprüfung: Existiert der neue Kunde?
        IF (SELECT COUNT(*) FROM customers WHERE customerID = p_newCustomer) = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Kunde nicht gefunden.';
        END IF;

    COMMIT;
    SELECT 'Erfolg: Bestellung übertragen.' AS status;
END$$

DELIMITER ;

-- Aufruf (Erfolg):   CALL sp_TransferOrder(10248, 'ALFKI');
-- Aufruf (Rollback): CALL sp_TransferOrder(10248, 'XXXXX');


-- -----------------------------------------------------------------------------
-- Beispiel 4: SAVEPOINT – Teilweises Rollback
-- -----------------------------------------------------------------------------
START TRANSACTION;

    INSERT INTO customers (customerID, companyName, city, country)
    VALUES ('SVP01', 'Savepoint GmbH', 'München', 'Germany');

    SAVEPOINT nach_kunde;

    -- Dieser INSERT soll scheitern
    INSERT INTO orders (customerID, employeeID, orderDate, shipperID, freight)
    VALUES ('SVP01', 99999, CURDATE(), 1, 0.00);

    -- Nur zurück zum Savepoint – der Kunde bleibt erhalten
    ROLLBACK TO SAVEPOINT nach_kunde;

COMMIT;
-- Ergebnis: Kunde 'SVP01' existiert, die fehlerhafte Bestellung nicht.


-- -----------------------------------------------------------------------------
-- Aufräumen (Demo-Daten entfernen)
-- -----------------------------------------------------------------------------
DELETE FROM orders    WHERE customerID IN ('NEUKD', 'SVP01');
DELETE FROM customers WHERE customerID IN ('NEUKD', 'TESTX', 'SVP01');
