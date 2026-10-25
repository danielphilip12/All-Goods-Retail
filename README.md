# AllGoodsRetail

## Project Overview

AllGoodsRetail is a synthetic retail data engineering and analytics
project built to simulate the data environment of a single retail store.

The project demonstrates an end-to-end workflow for generating realistic
relational data, applying business rules and validation, building an ETL
pipeline, loading the data into PostgreSQL, and using SQL to answer
business questions.

The goal is to demonstrate practical skills across **Python, data
generation, ETL, PostgreSQL, SQL, data validation, and business
analysis**.

------------------------------------------------------------------------

## Business Questions

The project is designed to answer questions such as:

-   What are the baseline sales and order metrics, including revenue and
    average order value?
-   Which products and categories lead in sales volume, revenue, and
    gross profit?
-   How do customer purchasing patterns differ by membership status?
-   How do promotional and non-promotional orders compare?
-   Which products and categories have the highest return volumes and
    return rates?
-   Which products are frequently purchased together, and which pairs
    have stronger-than-expected associations?

These questions guide the project's SQL analysis and planned Power BI
reporting.

------------------------------------------------------------------------

## Data Model

The database models several areas of a retail business, including:

-   Customers and membership
-   Products, categories, and aisles
-   Orders and order items
-   Payments
-   Returns
-   Promotions and promotion items
-   Suppliers and supplier/product relationships
-   Supplier deliveries

The model uses primary keys and foreign keys to maintain relationships
between entities and enforce referential integrity.

The supplier model also supports a many-to-many relationship between
suppliers and products, allowing a product to be supplied by multiple
suppliers and a supplier to provide multiple products.

------------------------------------------------------------------------

## Project Workflow

The project follows an end-to-end data pipeline:

``` text
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

------------------------------------------------------------------------

## Completed Work

### 1. Database Design

-   Designed the relational database schema.
-   Defined primary and foreign key relationships.
-   Established relationships between customers, orders, products,
    promotions, suppliers, and other entities.
-   Defined business rules for generated data.

### 2. Synthetic Data Generation

Built a Python-based data generator using **Pandas, NumPy, and Faker**.

The generator currently produces:

  Dataset                    Rows
  --------------------- ---------
  Customers                10,000
  Products                  1,000
  Product Categories           20
  Aisles                       30
  Promotions                  200
  Promotion Items           2,793
  Orders                  100,000
  Order Items             551,221
  Payments                100,000
  Returns                  42,480
  Suppliers                   120
  Supplier Products         1,199
  Supplier Deliveries     158,454

The generator uses a fixed random seed to make the generated dataset
reproducible.

### 3. Data Validation

Created a dedicated Python validation process to verify the generated
data before loading it into the database.

Validation includes checks for:

-   Row counts
-   Primary keys
-   Required fields
-   Foreign-key relationships
-   Customer membership history
-   Product data
-   Supplier/product relationships
-   Promotions
-   Orders and order totals
-   Payments
-   Returns
-   Supplier deliveries
-   Promotional pricing
-   Monetary values
-   Business-rule consistency

The generated dataset successfully passes the validation process.

### 4. Dockerized PostgreSQL Environment

The project uses **Docker Compose** to provide a reproducible local
database environment.

Current services include:

-   PostgreSQL
-   pgAdmin
-   Python environment for data generation and ETL

Environment variables are used for database configuration and
credentials rather than hard-coding them into the application.

### 5. ETL Pipeline

Built a Python ETL process that:

1.  Reads the generated CSV files.
2.  Loads the datasets in foreign-key dependency order.
3.  Connects to PostgreSQL using SQLAlchemy and `psycopg2`.
4.  Loads the data into the corresponding PostgreSQL tables.

The ETL process has been successfully tested from a clean PostgreSQL
database.

### 6. SQL Data Quality Validation

After loading the data into PostgreSQL, SQL-based data-quality checks
were performed to independently verify the database.

These checks include:

-   Table row counts
-   Required-field checks
-   Duplicate/primary-key checks
-   Business-rule checks
-   Referential-integrity checks
-   Order-total validation
-   Return validation
-   Promotion validation

The database has successfully passed the current data-quality checks.

### 7. Business-Focused SQL Analysis

Created a set of SQL analyses to investigate retail performance and
translate query results into business observations.

  -----------------------------------------------------------------------
  SQL file                            Analysis
  ----------------------------------- -----------------------------------
  `02_business_baseline.sql`          Establishes baseline metrics such
                                      as revenue, order count, average
                                      order value, customer counts, and
                                      returns.

  `03_product_sales.sql`              Compares product sales volume,
                                      revenue, and gross profit to
                                      identify strong and weak
                                      performers.

  `04_category_sales.sql`             Compares category performance using
                                      sales, revenue, gross profit,
                                      average selling price, and gross
                                      profit margin.

  `05_customer_analysis.sql`          Examines customer acquisition over
                                      time and compares order and revenue
                                      metrics by membership status.

  `06_promotion_analysis.sql`         Compares promotional and
                                      non-promotional orders and
                                      evaluates individual promotions by
                                      order volume, revenue, gross
                                      profit, average order value, and
                                      margin.

  `07_returns_analysis.sql`           Analyzes return records, refunds,
                                      returned units, product and
                                      category return rates, and products
                                      with elevated return rates.

  `08_product_affinity.sql`           Identifies frequently co-purchased
                                      product pairs and compares pair
                                      frequency with support, directional
                                      confidence, and lift.
                                      
------------------------------------------------------------------------
The analysis covers several important interpretation principles:

-   **Revenue and gross profit are different measures.** Gross profit is
    calculated from sales revenue less product cost and does not account
    for overhead or other operating expenses.
-   **Aggregation grain matters.** Order-level totals must not be summed
    after joining to multiple order-item rows unless the data is first
    aggregated to the order level.
-   **Return measures answer different questions.** Return records,
    returned units, refund amounts, order return rate, and unit return
    rate are not interchangeable.
-   **Associations do not prove causation.** Differences between
    promotional and non-promotional orders, and product co-purchase
    patterns, are observational findings rather than proof that one
    factor caused another.
-   **Product affinity uses multiple metrics.** Co-purchase count shows
    how frequently a pair appears, support measures its share of all
    orders, confidence measures how often one product appears with
    another, and lift compares observed co-purchasing with the
    expectation under independence.

The dataset is synthetic, so observed patterns demonstrate analytical
methods and should not be presented as evidence of actual retail
customer behavior. The SQL findings will inform the next phase of Power
BI reporting.

------------------------------------------------------------------------

## Technology Stack

### Data Generation & ETL

-   Python
-   Pandas
-   NumPy
-   Faker
-   SQLAlchemy
-   psycopg2

### Database

-   PostgreSQL
-   pgAdmin

### Infrastructure

-   Docker
-   Docker Compose

### Analysis & Visualization

-   SQL
-   Power BI *(next project phase)*

------------------------------------------------------------------------

## Project Structure

``` text
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
│   ├── 01_data_quality.sql
│   ├── 02_business_baseline.sql
│   ├── 03_product_sales.sql
│   ├── 04_category_sales.sql
│   ├── 05_customer_analysis.sql
│   ├── 06_promotion_analysis.sql
│   ├── 07_returns_analysis.sql
│   └── 08_product_affinity.sql
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── .env.example
├── .gitignore
├── db_diagram.md
├── ERD.md
└── README.md
```

------------------------------------------------------------------------

## Current Status

### Completed

-   [x] Database schema design
-   [x] Relational table design and relationships
-   [x] Business-rule definition
-   [x] Synthetic data generator
-   [x] Generated dataset
-   [x] Python data validation
-   [x] Dockerized PostgreSQL environment
-   [x] ETL pipeline
-   [x] PostgreSQL data load
-   [x] SQL data-quality validation
-   [x] Business baseline analysis
-   [x] Product and category sales analysis
-   [x] Customer and membership analysis
-   [x] Promotion effectiveness analysis
-   [x] Returns analysis
-   [x] Product affinity analysis using co-purchase count, support,
    confidence, and lift

### In Progress / Planned

-   [ ] Power BI reporting and visualization
-   [ ] Dashboard-focused refinement of business insights
-   [ ] Potential future cloud data warehouse implementation

------------------------------------------------------------------------

## Purpose

This project is intended to demonstrate the ability to work through a
realistic data workflow from **raw/generated data to a validated
relational database and business analysis**, rather than focusing solely
on individual analytical queries or visualizations.

## Project Startup

Follow these steps to generate, validate, and load the synthetic retail
data into PostgreSQL.

### 1. Configure environment variables

Create a `.env` file in the project root, using `.env.example` as a
guide for the required environment variables.

### 2. Build the Python environment

Run the following command to build the Python Docker image:

``` bash
docker compose build python
```

### 3. Start the Docker containers

Run the following command to start the services defined in
`docker-compose.yml`:

``` bash
docker compose up -d
```

### 4. Generate the synthetic data

Run the following command to generate the synthetic retail data:

``` bash
docker compose run --rm python python retail_data_generator/generator.py
```

This generates the CSV files used to populate the PostgreSQL database.

### 5. Validate the synthetic data

Run the following command to validate the generated CSV files:

``` bash
docker compose run --rm python python retail_data_generator/validate.py
```

This checks the generated data against the project's validation rules.
**Ensure validation passes before proceeding to the next step.**

### 6. Load the data into PostgreSQL

Run the following command to load the generated data into the database:

``` bash
docker compose run --rm python python etl/load_data.py
```

This connects to the PostgreSQL database and loads the CSV data into the
corresponding tables.
