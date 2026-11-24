# Geo Data ETL Pipeline

## Project Overview

This project implements a data engineering pipeline for processing geographical, population, and store master data.

The pipeline transforms raw source data into standardized and validated datasets, supporting store-level population allocation for Marketing Mix Modeling (MMM).

## Architecture

The project follows a Medallion Architecture:

- **Bronze:** Raw data ingestion.
- **Silver:** Data cleaning, standardization, and business transformations.
- **Gold:** Final curated store-level population allocation dataset.

## Technology Stack

- Azure Data Lake Storage Gen2
- Azure Databricks
- Apache Spark
- SQL
- Python
- Delta Lake
- GitHub

## Repository Structure

```text
geo-data/
├── docs/
├── notebooks/
├── sql/
├── src/
└── tests/
```

## Pipeline Workflow

1. Ingest geographical and store master source files.
2. Standardize raw datasets.
3. Map stores to geographical areas.
4. Calculate store-level population allocation.
5. Generate the final Gold dataset.
6. Perform data quality validations.

## Security

- Repository maintained as private.
- Never commit credentials, access keys, tokens, or confidential source data.
- Use secure credential management practices.

## Project Status

Development in progress.
