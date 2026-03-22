# Data Pipeline

## Overview
This pipeline extracts data from an RDS database, processes it, and uploads the results to an S3 bucket. The pipeline runs every **3 hours**, updating the S3 with the latest data from the database.

---

## Requirements

Before running the pipeline:

1. Create and activate a Python virtual environment.
2. Install the required dependencies.

```
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
````

Before running any file, navigate to the **Terraform** directory and apply the infrastructure configuration:

```
cd terraform
terraform apply
```

Terraform will provision the required AWS resources, including the **S3 bucket used to store the processed data**.

---

## Data Sources

The data extracted by `extract.py` comes from an **RDS database** containing **three tables joined together using an INNER JOIN**.

The pipeline requires environment variables stored in a `.env` file.

### AWS Credentials (from AWS Console)

```
ACCESS_KEY=
SECRET_ACCESS_KEY=
DEFAULT_REGION=
```

### RDS Credentials (from your RDS instance)

```
DB_HOST=
DB_NAME=
DB_PORT=
DB_USERNAME=
DB_PASSWORD=
```

---

## How to Run the Pipeline

1. Apply Terraform infrastructure:

```bash
terraform apply
```

2. Run the pipeline scripts in order:

```bash
python3 extract.py
python3 transform.py
python3 load.py
```

---

## Outputs

After running the pipeline:

* A **`data/` directory** will be created containing generated CSV files.
* A **Parquet file** containing the processed dataframe will be uploaded to the **S3 bucket**.
* Glue Crawler will run, allowing the dashboard to access the new data.

The Parquet files are **time-partitioned in S3** using the following structure:

```
year=YYYY/
  month=MM/
    day=DD/
      data.parquet
```

This structure enables efficient querying and partition pruning when using tools such as **Athena or Spark**.