-- =============================================================================
-- Northwind Database Schema
-- =============================================================================
-- Quelle:    Kaggle – Northwind Dataset
-- Datenbank: MySQL / MariaDB
-- Autor:     Marcel
-- =============================================================================

CREATE DATABASE IF NOT EXISTS northwind
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE northwind;

-- -----------------------------------------------------------------------------
-- 1. Kategorien
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categories (
    categoryID   INT          NOT NULL AUTO_INCREMENT,
    categoryName VARCHAR(50)  NOT NULL,
    description  TEXT,
    PRIMARY KEY (categoryID)
);

-- -----------------------------------------------------------------------------
-- 2. Versandunternehmen
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS shippers (
    shipperID   INT          NOT NULL AUTO_INCREMENT,
    companyName VARCHAR(100) NOT NULL,
    PRIMARY KEY (shipperID)
);

-- -----------------------------------------------------------------------------
-- 3. Kunden
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
    customerID   CHAR(5)      NOT NULL,
    companyName  VARCHAR(100) NOT NULL,
    contactName  VARCHAR(100),
    contactTitle VARCHAR(50),
    city         VARCHAR(50),
    country      VARCHAR(50),
    PRIMARY KEY (customerID)
);

-- -----------------------------------------------------------------------------
-- 4. Mitarbeiter
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS employees (
    employeeID   INT          NOT NULL AUTO_INCREMENT,
    employeeName VARCHAR(100) NOT NULL,
    title        VARCHAR(100),
    city         VARCHAR(50),
    country      VARCHAR(50),
    reportsTo    INT,
    PRIMARY KEY (employeeID),
    FOREIGN KEY (reportsTo) REFERENCES employees(employeeID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------
-- 5. Produkte
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
    productID       INT           NOT NULL AUTO_INCREMENT,
    productName     VARCHAR(100)  NOT NULL,
    quantityPerUnit VARCHAR(50),
    unitPrice       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    discontinued    TINYINT(1)    NOT NULL DEFAULT 0,
    categoryID      INT,
    PRIMARY KEY (productID),
    FOREIGN KEY (categoryID) REFERENCES categories(categoryID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------
-- 6. Bestellungen
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
    orderID      INT           NOT NULL AUTO_INCREMENT,
    customerID   CHAR(5),
    employeeID   INT,
    orderDate    DATE,
    requiredDate DATE,
    shippedDate  DATE,
    shipperID    INT,
    freight      DECIMAL(10,2) DEFAULT 0.00,
    PRIMARY KEY (orderID),
    FOREIGN KEY (customerID)  REFERENCES customers(customerID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (employeeID)  REFERENCES employees(employeeID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (shipperID)   REFERENCES shippers(shipperID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------
-- 7. Bestellpositionen
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_details (
    orderID   INT           NOT NULL,
    productID INT           NOT NULL,
    unitPrice DECIMAL(10,2) NOT NULL,
    quantity  SMALLINT      NOT NULL,
    discount  FLOAT         NOT NULL DEFAULT 0,
    PRIMARY KEY (orderID, productID),
    FOREIGN KEY (orderID)   REFERENCES orders(orderID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (productID) REFERENCES products(productID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
