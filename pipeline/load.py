import awswrangler as wr
import pandas as pd
import os
from dotenv import dotenv_values
import boto3

creds = dotenv_values(".env")

# Set AWS credentials as environment variables
os.environ['AWS_ACCESS_KEY_ID'] = creds.get('ACCESS_KEY')
os.environ['AWS_SECRET_ACCESS_KEY'] = creds.get('SECRET_ACCESS_KEY')
os.environ['AWS_DEFAULT_REGION'] = creds.get('DEFAULT_REGION')

recent_data = pd.read_csv('data/3_hour_data_cleaned.csv')

# ensure datetime and helper columns exist
recent_data["at"] = pd.to_datetime(recent_data["at"])
recent_data["year"] = recent_data["at"].dt.year
recent_data["month"] = recent_data["at"].dt.month
recent_data["day"] = recent_data["at"].dt.day


def upload_transaction_data():
    """Uploads transaction data to S3."""
    wr.s3.to_parquet(
        df=recent_data,
        path="s3://c22-lance-s3-bucket/T3_data/",
        dataset=True,
        partition_cols=["year", "month", "day"],
        mode="overwrite_partitions",
    )

    return "Upload complete!"


def trigger_crawler():
    """Triggers the Glue crawler to update the Athena table."""
    glue = boto3.client('glue')
    try:
        glue.start_crawler(Name='c22-lance-t3-crawler')
        return "Crawler started!"
    except glue.exceptions.CrawlerRunningException:
        return "Crawler already running."


if __name__ == "__main__":
    print(upload_transaction_data())
    trigger_crawler()
