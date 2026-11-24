
-- ============================================================
-- SOBEYS GEOGRAPHY PIPELINE
-- SILVER LAYER: DATA CLEANING AND STANDARDIZATION
-- Cleaning: TRIM, NULLIF and UPPER
-- ============================================================

USE CATALOG geo_data_databricks;
USE SCHEMA silver;


-- ============================================================
-- 1. CITY TABLE
-- ============================================================

CREATE OR REPLACE TABLE silver_city
USING DELTA AS

SELECT
    city_id_PK_SK AS city_id,
    NULLIF(TRIM(city_name), '') AS city_name,
    province_id_FK AS province_id,
    `_rescued_data`

FROM geo_data_databricks.bronze.raw_city;


-- ============================================================
-- 2. POPULATION TABLE
-- ============================================================

CREATE OR REPLACE TABLE silver_population
USING DELTA AS

SELECT
    population_id_PK_SK AS population_id,
    zipcode_id_FK AS zipcode_id,
    population_count,
    `_rescued_data`

FROM geo_data_databricks.bronze.raw_population;


-- ============================================================
-- 3. PROVINCE TABLE
-- ============================================================

CREATE OR REPLACE TABLE silver_province
USING DELTA AS

SELECT
    province_id_PK_SK AS province_id,
    NULLIF(TRIM(province_name), '') AS province_name,
    UPPER(NULLIF(TRIM(province_code), '')) AS province_code,
    `_rescued_data`

FROM geo_data_databricks.bronze.raw_province;


-- ============================================================
-- 4. ZIPCODE TABLE
-- ============================================================

CREATE OR REPLACE TABLE silver_zipcode
USING DELTA AS

SELECT
    zipcode_id_PK_SK AS zipcode_id,
    UPPER(NULLIF(TRIM(zip_code), '')) AS fsa_code,
    city_id_FK AS city_id,
    `_rescued_data`

FROM geo_data_databricks.bronze.raw_zipcode;


-- ============================================================
-- 5. STORE MASTER TABLE
-- ============================================================

CREATE OR REPLACE TABLE silver_store_master
USING DELTA AS

SELECT
    store_id,
    NULLIF(TRIM(banner), '') AS banner,
    NULLIF(TRIM(city), '') AS city_name,
    UPPER(NULLIF(TRIM(fsa), '')) AS fsa_code,
    NULLIF(TRIM(province), '') AS province_name,
    NULLIF(TRIM(ownership_type), '') AS ownership_type,
    NULLIF(TRIM(store_format), '') AS store_format,
    store_size,
    NULLIF(TRIM(store_category), '') AS store_category,
    NULLIF(TRIM(area_profile), '') AS area_profile,
    fsa_population,
    `_rescued_data`

FROM geo_data_databricks.bronze.raw_store_master;


-- ============================================================
-- SILVER TRANSFORMATION COMPLETED
-- String columns cleaned and standardized.
-- Numeric columns and key data types preserved.
-- ============================================================


USE CATALOG geo_data_databricks;


-- ============================================================
-- STEP 1: CREATE FSA POPULATION TABLE
-- Join population, zipcode, city and province
-- No aggregation is required for the current dataset
-- ============================================================

CREATE OR REPLACE TABLE
geo_data_databricks.silver.silver_fsa_population
USING DELTA AS

SELECT
    z.fsa_code,
    p.province_name,
    pop.population_count

FROM geo_data_databricks.silver.silver_population pop

INNER JOIN geo_data_databricks.silver.silver_zipcode z
    ON pop.zipcode_id = z.zipcode_id

INNER JOIN geo_data_databricks.silver.silver_city c
    ON z.city_id = c.city_id

INNER JOIN geo_data_databricks.silver.silver_province p
    ON c.province_id = p.province_id;


-- ============================================================
-- STEP 2: MAP STORES TO FSA POPULATION
-- Join using FSA only
-- ============================================================

CREATE OR REPLACE TABLE
geo_data_databricks.silver.silver_store_fsa_mapping
USING DELTA AS

SELECT
    s.store_id,
    s.banner,
    s.city_name,
    s.province_name,
    s.fsa_code,
    s.store_size,
    f.population_count

FROM geo_data_databricks.silver.silver_store_master s

INNER JOIN geo_data_databricks.silver.silver_fsa_population f
    ON s.fsa_code = f.fsa_code;


-- ============================================================
-- STEP 3: CALCULATE STORE AREA SHARE
-- Each store's size divided by total store size within its FSA
-- ============================================================

CREATE OR REPLACE TABLE
geo_data_databricks.silver.silver_store_area_share
USING DELTA AS

SELECT
    store_id,
    banner,
    city_name,
    province_name,
    fsa_code,
    store_size,
    population_count,

    CAST(store_size AS DECIMAL(38, 6))
    /
    NULLIF(
        SUM(CAST(store_size AS DECIMAL(38, 6)))
        OVER (PARTITION BY fsa_code),
        0
    ) AS store_area_share

FROM geo_data_databricks.silver.silver_store_fsa_mapping;


-- ============================================================
-- STEP 4: CALCULATE STORE POPULATION ALLOCATION
-- FSA population multiplied by store area share
-- ============================================================

CREATE OR REPLACE TABLE
geo_data_databricks.silver.silver_store_population_allocation
USING DELTA AS

SELECT
    store_id,
    banner,
    city_name,
    province_name,
    fsa_code,
    store_size,
    store_area_share,
    population_count,

    CAST(population_count AS DECIMAL(38, 6))
    * store_area_share AS population_share_value

FROM geo_data_databricks.silver.silver_store_area_share;
