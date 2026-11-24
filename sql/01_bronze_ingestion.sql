
-- ============================================================
-- SOBEYS GEOGRAPHY PIPELINE
-- BRONZE LAYER: RAW DATA INGESTION
-- Purpose : Load source CSV files into Delta tables
-- Catalog : geo_data_databricks
-- Schema  : bronze
-- ============================================================


-- Select project catalog and Bronze schema

USE CATALOG geo_data_databricks;
USE SCHEMA bronze;


-- ============================================================
-- 1. CITY DATA INGESTION
-- Source : dim_city_clean.csv
-- Target : bronze.raw_city
-- ============================================================

CREATE OR REPLACE TABLE geo_data_databricks.bronze.raw_city
USING DELTA AS

SELECT *
FROM read_files(
    '/Volumes/geo_data_databricks/bronze/raw-csv-files/dim_city_clean.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    rescuedDataColumn => '_rescued_data'
);


-- ============================================================
-- 2. POPULATION DATA INGESTION
-- Source : dim_population.csv
-- Target : bronze.raw_population
-- ============================================================

CREATE OR REPLACE TABLE geo_data_databricks.bronze.raw_population
USING DELTA AS

SELECT *
FROM read_files(
    '/Volumes/geo_data_databricks/bronze/raw-csv-files/dim_population.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    rescuedDataColumn => '_rescued_data'
);


-- ============================================================
-- 3. PROVINCE DATA INGESTION
-- Source : dim_province.csv
-- Target : bronze.raw_province
-- ============================================================

CREATE OR REPLACE TABLE geo_data_databricks.bronze.raw_province
USING DELTA AS

SELECT *
FROM read_files(
    '/Volumes/geo_data_databricks/bronze/raw-csv-files/dim_province.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    rescuedDataColumn => '_rescued_data'
);


-- ============================================================
-- 4. ZIPCODE DATA INGESTION
-- Source : dim_zipcode_clean.csv
-- Target : bronze.raw_zipcode
-- ============================================================

CREATE OR REPLACE TABLE geo_data_databricks.bronze.raw_zipcode
USING DELTA AS

SELECT *
FROM read_files(
    '/Volumes/geo_data_databricks/bronze/raw-csv-files/dim_zipcode_clean.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    rescuedDataColumn => '_rescued_data'
);


-- ============================================================
-- 5. STORE MASTER DATA INGESTION
-- Source : store_master.csv
-- Target : bronze.raw_store_master
-- ============================================================

CREATE OR REPLACE TABLE geo_data_databricks.bronze.raw_store_master
USING DELTA AS

SELECT *
FROM read_files(
    '/Volumes/geo_data_databricks/bronze/raw-csv-files/store_master.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    rescuedDataColumn => '_rescued_data'
);


-- ============================================================
-- BRONZE INGESTION COMPLETED
-- Five source CSV files loaded into Delta tables.
-- Schema inference and rescued-data capture configured.
-- ============================================================
