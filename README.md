# Sobeys Geography ETL Pipeline

## 1. Project Overview

The Sobeys Geography ETL Pipeline processes geographical, population and store master data to generate store-level population allocation weights.

The resulting Gold dataset supports the allocation of province-level marketing expenditure across individual stores for Marketing Mix Modeling (MMM).

## 2. Technology Stack

- **Cloud Platform:** Microsoft Azure
- **Storage:** Azure Data Lake Storage Gen2 (ADLS Gen2)
- **Data Processing:** Azure Databricks
- **Processing Engine:** Apache Spark
- **Query Language:** SQL
- **Programming Language:** Python
- **Storage Format:** Delta Lake
- **Version Control:** Git and GitHub

## 3. Architecture

The pipeline follows the Medallion Architecture.

### Bronze Layer – Raw Data Ingestion

Loads five source CSV files into Delta tables.

| Source File | Target Table |
|---|---|
| `dim_city_clean.csv` | `bronze.raw_city` |
| `dim_population.csv` | `bronze.raw_population` |
| `dim_province.csv` | `bronze.raw_province` |
| `dim_zipcode_clean.csv` | `bronze.raw_zipcode` |
| `store_master.csv` | `bronze.raw_store_master` |

### Silver Layer – Standardization and Business Transformations

**Data Standardization**

- Clean string values using `TRIM()`.
- Convert empty strings into NULL using `NULLIF()`.
- Standardize geographical codes using `UPPER()`.
- Preserve rescued data for further investigation.

**Business Transformations**

1. Create FSA population mapping using population, zipcode, city and province tables.
2. Map stores to FSA population.
3. Calculate store area share within each FSA.
4. Allocate FSA population to individual stores using store area share.

Intermediate Silver tables:

- `silver.silver_fsa_population`
- `silver.silver_store_fsa_mapping`
- `silver.silver_store_area_share`
- `silver.silver_store_population_allocation`

### Gold Layer – Final Store-Level Population Weights

Creates the final curated table:

`gold.gold_store_population`

The pipeline calculates each store's percentage weight within its province based on its allocated population share.

The final dataset includes:

- Store ID
- Banner
- City name
- Province name
- FSA code
- Store size
- Store area share
- Population count
- Population share value
- Province population weight percentage

## 4. Pipeline Workflow

1. Ingest source CSV files from ADLS Gen2.
2. Create Bronze Delta tables.
3. Standardize source data in Silver.
4. Generate FSA-level population mapping.
5. Map stores to their corresponding FSA population.
6. Calculate store area share.
7. Allocate population to individual stores.
8. Generate final Gold store population weights.
9. Perform data quality validation.
10. Export the Gold dataset to ADLS Gen2 in CSV format.

## 5. Repository Structure

```text
geo-data/
│
├── docs/
│   └── Project documentation
│
├── notebooks/
│   └── Databricks notebooks
│
├── sql/
│   ├── 01_bronze_ingestion.sql
│   ├── 02_silver_transformation.sql
│   └── 03_gold_transformation.sql
│
├── src/
│   └── export_gold_to_adls.py
│
└── tests/
    └── Data quality and validation scripts
```

## 6. Data Quality

The pipeline includes validation checks for:

- Record count
- Duplicate store IDs
- NULL values in required columns
- Negative numerical values
- Rescued data records

## 7. Output

**Gold Table:** `geo_data_databricks.gold.gold_store_population`

**Export Format:** CSV

**Storage Location:** ADLS Gen2 – `gold-outputs/gold_store_population_csv/`

## 8. Security and Version Control

- Repository visibility is Private.
- Never commit credentials, access keys, tokens or confidential source datasets.
- Use secure credential management practices.
- Maintain meaningful commit messages.
- Use feature branches for development.
- Review changes before merging into the main branch.

## 9. Project Status

Geography and store population allocation pipeline implemented. Further development and integration with marketing spend allocation are planned.
