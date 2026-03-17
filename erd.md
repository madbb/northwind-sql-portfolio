# Northwind – Datenbankschema (ERD)


```mermaid
erDiagram
  categories {
    int categoryID PK
    varchar categoryName
    text description
  }
  products {
    int productID PK
    varchar productName
    varchar quantityPerUnit
    decimal unitPrice
    tinyint discontinued
    int categoryID FK
  }
  order_details {
    int orderID PK_FK
    int productID PK_FK
    decimal unitPrice
    smallint quantity
    float discount
  }
  orders {
    int orderID PK
    char customerID FK
    int employeeID FK
    date orderDate
    date shippedDate
    int shipperID FK
    decimal freight
  }
  customers {
    char customerID PK
    varchar companyName
    varchar contactName
    varchar contactTitle
    varchar city
    varchar country
  }
  employees {
    int employeeID PK
    varchar employeeName
    varchar title
    varchar city
    varchar country
    int reportsTo FK
  }
  shippers {
    int shipperID PK
    varchar companyName
  }

  categories    ||--o{ products      : "hat"
  products      ||--o{ order_details : "enthalten in"
  orders        ||--|{ order_details : "beinhaltet"
  customers     ||--o{ orders        : "gibt auf"
  employees     ||--o{ orders        : "bearbeitet"
  shippers      ||--o{ orders        : "versendet"
  employees     }o--o| employees     : "reportsTo"
```

## Legende

| Symbol | Bedeutung |
|--------|-----------|
| `PK`   | Primary Key |
| `FK`   | Foreign Key |
| `\|\|--o{` | Eins zu viele (optional) |
| `\|\|--\|{` | Eins zu viele (pflicht) |
| `}o--o\|` | Self-Join (employees → Vorgesetzter) |
