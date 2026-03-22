from pathlib import Path
import pymysql.cursors
from dotenv import dotenv_values
import csv

creds = dotenv_values(".env")
Path("backfill_data").mkdir(exist_ok=True)


# Connect to the database
connection = pymysql.connect(host=creds.get("DB_HOST"),
                             user=creds.get("DB_USERNAME"),
                             password=creds.get("DB_PASSWORD"),
                             database=creds.get("DB_NAME"),
                             port=int(creds.get("DB_PORT")),
                             charset='utf8mb4',
                             cursorclass=pymysql.cursors.DictCursor)

with connection:
    with connection.cursor() as cursor:
        sql = """
            SELECT
                *
            FROM
                DIM_Truck as dt
            JOIN
                FACT_Transaction as ft
            ON
                dt.truck_id = ft.truck_id
            JOIN
                DIM_Payment_Method as dpm
            ON
                ft.payment_method_id = dpm.payment_method_id
            """
        cursor.execute(sql)
        T3_tables = cursor.fetchall()

if not T3_tables:
    print("No data found.")
else:
    path = f"backfill_data/backfill_data_raw.csv"
    with open(path, mode="w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=T3_tables[0].keys())
        writer.writeheader()
        writer.writerows(T3_tables)
