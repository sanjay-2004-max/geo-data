# EXPORT GOLD TABLE TO ADLS GEN2 AS CSV

# Read the final Gold table
gold_df = spark.table(
    "geo_data_databricks.gold.gold_store_population"
)

# Define ADLS Gen2 output path
output_path = (
    "abfss://geo-data@geodatademo.dfs.core.windows.net/"
    "gold-outputs/gold_store_population_csv/"
)

# Write the Gold table as CSV
gold_df.coalesce(1) \
    .write \
    .format("csv") \
    .option("header", "true") \
    .mode("overwrite") \
    .save(output_path)

print("Gold table successfully exported to ADLS Gen2!")
print("Output location:", output_path)
