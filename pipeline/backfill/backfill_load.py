import awswrangler as wr
import pandas as pd
import os
from dotenv import dotenv_values

creds = dotenv_values(".env")

# Set AWS credentials as environment variables
os.environ['AWS_ACCESS_KEY_ID'] = creds.get('ACCESS_KEY')
os.environ['AWS_SECRET_ACCESS_KEY'] = creds.get('SECRET_ACCESS_KEY')
os.environ['AWS_DEFAULT_REGION'] = creds.get('DEFAULT_REGION')

backfill_data = pd.read_csv('backfill_data/backfill_data_cleaned.csv')

# ensure datetime and helper columns exist
backfill_data["at"] = pd.to_datetime(backfill_data["at"])
backfill_data["year"] = backfill_data["at"].dt.year
backfill_data["month"] = backfill_data["at"].dt.month
backfill_data["day"] = backfill_data["at"].dt.day


def upload_transaction_data():
    """Uploads transaction data to S3."""
    wr.s3.to_parquet(
        df=backfill_data,
        path="s3://c22-lance-s3-bucket/T3_data/",
        dataset=True,
        partition_cols=["year", "month", "day"],
        mode="overwrite",
    )

    return "Upload complete!"


if __name__ == "__main__":
    print(upload_transaction_data())
