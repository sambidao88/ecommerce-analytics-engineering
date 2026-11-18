import duckdb

LOCAL_DB = r"C:\ecommerce-backup\ecommerce.duckdb"
TARGET_DB = "ecommerce_portfolio"

print("Connecting to MotherDuck...")

con = duckdb.connect("md:")

print("Attaching local DuckDB...")
con.execute(
    f"ATTACH '{LOCAL_DB}' AS local_db"
)

print("Copying database...")
con.execute(
    f"COPY FROM DATABASE local_db TO {TARGET_DB}"
)

print("Upload completed!")

con.close()