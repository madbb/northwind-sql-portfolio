# 🗄️ Northwind SQL Portfolio

> Vollständige SQL-Analyse der klassischen Northwind-Datenbank –  
> von Setup & Import bis zu Business Insights, Views und Stored Procedures.

---

## 📌 Projektübersicht

Dieses Projekt demonstriert praxisnahe SQL-Kenntnisse anhand der **Northwind-Datenbank** –  
einem fiktiven Handelsunternehmen mit Kunden, Bestellungen, Produkten und Mitarbeitern.

| Eigenschaft     | Details                              |
|-----------------|--------------------------------------|
| **Datenbank**   | MySQL / MariaDB                      |
| **Datenbasis**  | [Northwind Dataset – Kaggle](https://www.kaggle.com/datasets/cleveranjosqlik/csv-northwind-database) |
| **Datensätze**  | 7 Tabellen, ~3.200 Zeilen            |
| **Schwerpunkte** | Abfragen, DML, Views, Stored Procedures, Transactions |

---

## 📂 Projektstruktur

```
northwind-sql-portfolio/
│
├── 📁 01_setup/
│   ├── 01_schema.sql          # CREATE TABLE mit Fremdschlüsseln
│   └── 02_import.sql          # LOAD DATA INFILE für alle CSVs
│
├── 📁 02_queries/
│   ├── 01_basic_queries.sql   # SELECT, WHERE, GROUP BY, HAVING
│   └── 02_advanced_queries.sql # JOINs, Subqueries, CASE, ABC-Analyse
│
├── 📁 03_dml/
│   ├── 01_dml_basics.sql      # INSERT, UPDATE, DELETE (⭐ bis ⭐⭐⭐)
│   └── 02_dml_advanced.sql    # UPSERT, CASE in UPDATE, CASCADE (⭐⭐⭐ bis ⭐⭐⭐⭐)
│
├── 📁 04_views/
│   └── 01_views.sql           # 4 Business-Views
│
├── 📁 05_stored_procedures/
│   └── 01_stored_procedures.sql  # 4 Stored Procedures mit Parametern
│
├── 📁 06_transactions/
│   └── 01_transactions.sql    # ACID, ROLLBACK, SAVEPOINT, Error Handler
│
└── 📁 data/
    ├── categories.csv
    ├── customers.csv
    ├── employees.csv
    ├── orders.csv
    ├── order_details.csv
    ├── products.csv
    └── shippers.csv
```

---

## 🚀 Schnellstart

### 1. Schema erstellen
```sql
SOURCE 01_setup/01_schema.sql;
```

### 2. Daten importieren
```sql
-- Pfad zu den CSV-Dateien anpassen, dann:
SOURCE 01_setup/02_import.sql;
```

### 3. Ergebnis prüfen
```sql
SELECT 'orders' AS t, COUNT(*) FROM orders
UNION ALL
SELECT 'customers',   COUNT(*) FROM customers;
-- Erwartung: 830 / 91
```

---

## 🔍 Highlights

### 📊 Business Insights (Advanced Queries)

**Top 10 Kunden nach Umsatz** – mit Rabatt-bereinigtem Nettoumsatz  
**ABC-Kundensegmentierung** – automatische Einordnung in A / B / C  
**Mitarbeiter-Performance** – Umsatz und Bestellanzahl pro Mitarbeiter  
**Lieferverzögerung** – Durchschnittliche Lieferzeiten pro Versandunternehmen  

### 🏗️ Datenbankdesign

- Normalisiertes Schema (3NF)
- Fremdschlüssel mit `ON DELETE` / `ON UPDATE` Regeln
- Self-JOIN bei `employees` (Hierarchie: Mitarbeiter → Vorgesetzter)

### ✏️ DML – Datenmanipulation

**14 praxisnahe Szenarien** in zwei Schwierigkeitsstufen:

| Datei | Themen |
|-------|--------|
| `01_dml_basics.sql` | Multi-Row INSERT, UPDATE mit JOIN, DELETE mit Subquery |
| `02_dml_advanced.sql` | UPSERT (`ON DUPLICATE KEY`), CASE in UPDATE, CASCADE-Demo |

### ⚙️ Stored Procedures

| Procedure | Beschreibung |
|-----------|-------------|
| `sp_GetCustomersByCountry` | Kunden nach Land filtern |
| `sp_TopProductsByRevenue`  | Top-N Produkte nach Umsatz |
| `sp_CreateOrder`           | Neue Bestellung mit Fehlerbehandlung |
| `sp_RevenueReport`         | Umsatz-Report für Zeitraum |

### 🔒 Transactions & Fehlerbehandlung

```sql
-- Automatischer Rollback bei SQL-Fehler
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    ROLLBACK;
END;
```

---

## 📈 Datenbankschema (ERD)

→ [Vollständiges ERD mit allen Spalten ansehen](erd.md)

```
categories ──< products ──< order_details >── orders >── customers
                                                  │
                                             employees (self-join)
                                                  │
                                              shippers
```

---

## 🛠️ Verwendete Konzepte

| Bereich | Konzepte |
|---------|----------|
| **Abfragen**     | SELECT, WHERE, JOIN (INNER/LEFT/SELF), GROUP BY, HAVING, ORDER BY |
| **Funktionen**   | COUNT, SUM, AVG, MIN, MAX, ROUND, COALESCE, CONCAT, DATEDIFF, YEAR, MONTH |
| **Subqueries**   | IN, NOT IN, korrelierte Subqueries |
| **DML**          | INSERT, UPDATE, DELETE, UPSERT (INSERT … ON DUPLICATE KEY) |
| **Views**        | CREATE OR REPLACE VIEW, virtuelle Tabellen |
| **Procedures**   | IN/OUT Parameter, DELIMITER, LAST_INSERT_ID() |
| **Transactions** | START TRANSACTION, COMMIT, ROLLBACK, SAVEPOINT, DECLARE EXIT HANDLER |
| **Design**       | Normalisierung, Fremdschlüssel, CASCADE-Optionen |

---

## 📚 Datenquelle

Die Rohdaten stammen aus dem öffentlichen Northwind-Datensatz auf Kaggle:  
[https://www.kaggle.com/datasets/cleveranjosqlik/csv-northwind-database](https://www.kaggle.com/datasets/cleveranjosqlik/csv-northwind-database)

---

*Erstellt mit MySQL / MariaDB & HeidiSQL*
