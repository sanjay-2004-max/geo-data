-- ============================================================
-- STEP 5: Create final Gold table
-- Calculate each store's percentage weight within its province
-- ============================================================

CREATE OR REPLACE TABLE
geo_data_databricks.gold.gold_store_population
USING DELTA AS

SELECT
    *,

    (
        population_share_value
        /
        NULLIF(
            SUM(population_share_value)
            OVER (PARTITION BY province_name),
            0
        )
    ) * 100 AS province_population_weight_percentage

FROM geo_data_databricks.silver.silver_store_population_allocation;
