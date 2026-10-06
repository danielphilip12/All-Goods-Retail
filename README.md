# AllGoodsRetail

## Project Overview

AllGoodsRetail is a synthetic retail data engineering and analytics project built to simulate the data environment of a single retail store.

The project demonstrates an end-to-end workflow for generating realistic relational data, applying business rules and validation, building an ETL pipeline, loading the data into PostgreSQL, and using SQL to answer business questions.

The goal is to demonstrate practical skills across **Python, data generation, ETL, PostgreSQL, SQL, data validation, and business analysis**.

---

## Business Questions

The project is designed to answer questions such as:

- How much profit are we generating?
- What is the best-selling product/category?
- What is the most profitable category?
- What items are frequently sold together?
- What product is returned the most?
- How do promotions affect sales?
- How many customers are members?
- How many new members do we get each month?

These questions will form the basis of the project's analytical phase.

---

## Data Model

The database models several areas of a retail business, including:

- Customers and membership
- Products, categories, and aisles
- Orders and order items
- Payments
- Returns
- Promotions and promotion items
- Suppliers and supplier/product relationships
- Supplier deliveries

The model uses primary keys and foreign keys to maintain relationships between entities and enforce referential integrity.

The supplier model also supports a many-to-many relationship between suppliers and products, allowing a product to be supplied by multiple suppliers and a supplier to provide multiple products.

---

## Project Workflow

The project follows an end-to-end data pipeline:

```text
Synthetic Data Generation
          ↓
Data Validation
          ↓
CSV Data
          ↓
ETL Pipeline
          ↓
PostgreSQL
          ↓
SQL Data Quality Checks
          ↓
Business Analysis
          ↓
Power BI
```

---

## Completed Work

### 1. Database Design

- Designed the relational database schema.
- Defined primary and foreign key relationships.
- Established relationships between customers, orders, products, promotions, suppliers, and other entities.
- Defined business rules for generated data.

### 2. Synthetic Data Generation

Built a Python-based data generator using **Pandas, NumPy, and Faker**.

The generator currently produces:

| Dataset | Rows |
|---|---:|
| Customers | 10,000 |
| Products | 1,000 |
| Product Categories | 20 |
| Aisles | 30 |
| Promotions | 200 |
| Promotion Items | 2,793 |
| Orders | 100,000 |
| Order Items | 551,221 |
| Payments | 100,000 |
| Returns | 42,480 |
| Suppliers | 120 |
| Supplier Products | 1,199 |
| Supplier Deliveries | 158,454 |

The generator uses a fixed random seed to make the generated dataset reproducible.

### 3. Data Validation

Created a dedicated Python validation process to verify the generated data before loading it into the database.

Validation includes checks for:

- Row counts
- Primary keys
- Required fields
- Foreign-key relationships
- Customer membership history
- Product data
- Supplier/product relationships
- Promotions
- Orders and order totals
- Payments
- Returns
- Supplier deliveries
- Promotional pricing
- Monetary values
- Business-rule consistency

The generated dataset successfully passes the validation process.

### 4. Dockerized PostgreSQL Environment

The project uses **Docker Compose** to provide a reproducible local database environment.

Current services include:

- PostgreSQL
- pgAdmin
- Python environment for data generation and ETL

Environment variables are used for database configuration and credentials rather than hard-coding them into the application.

### 5. ETL Pipeline

Built a Python ETL process that:

1. Reads the generated CSV files.
2. Loads the datasets in foreign-key dependency order.
3. Connects to PostgreSQL using SQLAlchemy and `psycopg2`.
4. Loads the data into the corresponding PostgreSQL tables.

The ETL process has been successfully tested from a clean PostgreSQL database.

### 6. SQL Data Quality Validation

After loading the data into PostgreSQL, SQL-based data-quality checks were performed to independently verify the database.

These checks include:

- Table row counts
- Required-field checks
- Duplicate/primary-key checks
- Business-rule checks
- Referential-integrity checks
- Order-total validation
- Return validation
- Promotion validation

The database has successfully passed the current data-quality checks.

---

## Technology Stack

### Data Generation & ETL
- Python
- Pandas
- NumPy
- Faker
- SQLAlchemy
- psycopg2

### Database
- PostgreSQL
- pgAdmin

### Infrastructure
- Docker
- Docker Compose

### Analysis & Visualization
- SQL
- Power BI *(planned)*

---

## Project Structure

```text
AllGoodsRetail/
├── database/
│   └── schema.sql
├── etl/
│   └── load_data.py
├── retail_data_generator/
│   ├── config.py
│   ├── generator.py
│   └── validate.py
├── sql/
│   └── 01_data_quality.sql
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── .env.example
├── .gitignore
├── db_diagram.md
├── ERD.md
└── README.md
```

---

## Current Status

### Completed
- [x] Database schema design
- [x] Relational table design and relationships
- [x] Business-rule definition
- [x] Synthetic data generator
- [x] Generated dataset
- [x] Python data validation
- [x] Dockerized PostgreSQL environment
- [x] ETL pipeline
- [x] PostgreSQL data load
- [x] SQL data-quality validation

### In Progress / Planned
- [ ] Exploratory and business-focused SQL analysis
- [ ] Analytical SQL queries/views
- [ ] Power BI reporting and visualization
- [ ] Additional analytical insights and recommendations
- [ ] Potential future cloud data warehouse implementation

---

## Purpose

This project is intended to demonstrate the ability to work through a realistic data workflow from **raw/generated data to a validated relational database and business analysis**, rather than focusing solely on individual analytical queries or visualizations.
