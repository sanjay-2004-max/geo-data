
# ============================================================
# DATA QUALITY VALIDATION - SOBEYS GEO DATA PIPELINE
# ============================================================

# STEP 1: SET CATALOG AND TABLE NAME

spark.sql("USE CATALOG geo_data_databricks")

table_name = "geo_data_databricks.gold.gold_store_population"

print("Starting Data Quality Validation...")
print("Target Table:", table_name)


# ============================================================
# CHECK 1: TOTAL RECORD COUNT
# ============================================================

record_count = spark.sql(f"""
    SELECT COUNT(*) AS total_records
    FROM {table_name}
""").collect()[0]["total_records"]

if record_count > 0:
    print(f"PASS - Record Count: {record_count} records found.")
else:
    raise Exception("FAIL - Gold table is empty!")


# ============================================================
# CHECK 2: DUPLICATE STORE ID
# ============================================================

duplicate_count = spark.sql(f"""
    SELECT COUNT(*) AS duplicate_groups
    FROM (
        SELECT store_id
        FROM {table_name}
        GROUP BY store_id
        HAVING COUNT(*) > 1
    )
""").collect()[0]["duplicate_groups"]

if duplicate_count == 0:
    print("PASS - No duplicate Store IDs found.")
else:
    raise Exception(
        f"FAIL - {duplicate_count} duplicate Store ID groups found!"
    )


# ============================================================
# CHECK 3: NULL VALUE CHECK
# ============================================================

null_result = spark.sql(f"""
    SELECT
        COUNT_IF(store_id IS NULL) AS missing_store_id,
        COUNT_IF(fsa_code IS NULL) AS missing_fsa_code,
        COUNT_IF(population_count IS NULL) AS missing_population,
        COUNT_IF(store_size IS NULL) AS missing_store_size,
        COUNT_IF(store_area_share IS NULL) AS missing_area_share,
        COUNT_IF(population_share_value IS NULL) AS missing_population_allocation,
        COUNT_IF(province_population_weight_percentage IS NULL)
            AS missing_province_weight
    FROM {table_name}
""").collect()[0]

null_failures = {
    column: null_result[column]
    for column in null_result.asDict()
    if null_result[column] > 0
}

if not null_failures:
    print("PASS - No NULL values found in required columns.")
else:
    raise Exception(f"FAIL - NULL values detected: {null_failures}")


# ============================================================
# CHECK 4: NEGATIVE VALUE CHECK
# ============================================================

negative_count = spark.sql(f"""
    SELECT COUNT(*) AS negative_records
    FROM {table_name}
    WHERE
        store_size < 0
        OR population_count < 0
        OR store_area_share < 0
        OR population_share_value < 0
        OR province_population_weight_percentage < 0
""").collect()[0]["negative_records"]

if negative_count == 0:
    print("PASS - No negative values found.")
else:
    raise Exception(
        f"FAIL - {negative_count} records contain negative values!"
    )


# ============================================================
# CHECK 5: RESCUED DATA VALIDATION
# ============================================================

silver_tables = [
    "silver_city",
    "silver_population",
    "silver_province",
    "silver_zipcode",
    "silver_store_master"
]

for table in silver_tables:

    rescued_count = spark.sql(f"""
        SELECT COUNT(*) AS rescued_records
        FROM geo_data_databricks.silver.{table}
        WHERE `_rescued_data` IS NOT NULL
    """).collect()[0]["rescued_records"]

    if rescued_count == 0:
        print(f"PASS - {table}: No rescued records found.")
    else:
        raise Exception(
            f"FAIL - {table}: {rescued_count} rescued records found. "
            "Investigate the rescued data."
        )


# ============================================================
# FINAL VALIDATION STATUS
# ============================================================

print("\n===================================")
print("ALL DATA QUALITY CHECKS PASSED")
print("===================================")

print("Total Records:", record_count)
print("Duplicate Store IDs: 0")
print("NULL Value Issues: 0")
print("Negative Value Records: 0")
print("Rescued Data Issues: 0")

print("Overall Status: PASS")
