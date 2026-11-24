# SQL Scripts

This folder contains SQL scripts for the Sobeys Geography ETL pipeline.

## Scripts

1. `01_bronze_ingestion.sql` – Ingests five source CSV files into Bronze Delta tables.
2. `02_silver_transformation.sql` – Performs data cleaning, standardization and Silver business transformations.
3. `03_gold_transformation.sql` – Creates the final Gold store-level population allocation table.
