# Tasty Truck Treats (T3) — Data Lake Migration

## Project Overview

**Tasty Truck Treats (T3)** is a food truck catering company operating across Lichfield and its surrounding areas. Each truck operates semi-independently, collecting sales data every few hours and uploading it to a central database.

This project migrates T3's data from an **AWS RDS (MySQL) instance** to a cost-effective **AWS Data Lake** architecture. It covers:

- **Historical data migration** (backfill): transferring all existing transaction records from RDS into the data lake.
- **Periodic data migration**: an automated ETL pipeline that runs every 3 hours, extracting new transaction data from RDS, transforming it, and uploading it to S3 as partitioned Parquet files.
- **Interactive dashboard**: a Streamlit application that reads from the data lake (via Athena) and displays key food truck performance metrics.
- **Automated daily report**: a Lambda function that generates an HTML summary report of the previous day's transactions, delivered to S3 every morning at 09:30 AM.

All infrastructure is provisioned with **Terraform** and all services are containerised with **Docker**.

---


## Prerequisites

Ensure the following tools are installed and configured before starting:

| Tool | Purpose |
|---|---|
| **AWS CLI** | Authenticating with AWS |
| **Docker** | Building and running containers |
| **Terraform** | Provisioning cloud infrastructure |
| **Python 3.x** | Running pipeline and dashboard scripts |

---

## Environment Variables

Each service requires a `.env` file in its own directory. Use the templates below.

### `pipeline/.env` and `pipeline/backfill/.env`

```
ACCESS_KEY=<your_aws_access_key>
SECRET_ACCESS_KEY=<your_aws_secret_access_key>
DEFAULT_REGION=<your_aws_region>

DB_HOST=<rds_host>
DB_NAME=<database_name>
DB_PORT=<database_port>
DB_USERNAME=<database_username>
DB_PASSWORD=<database_password>
```

### `dashboard/.env`

```
AWS_ACCESS_KEY_ID=<your_aws_access_key>
AWS_SECRET_ACCESS_KEY=<your_aws_secret_access_key>
AWS_DEFAULT_REGION=<your_aws_region>
```

---

## Installing Dependencies

Install Python dependencies for each service individually:

```bash
pip install -r pipeline/requirements.txt
pip install -r dashboard/requirements.txt
pip install -r report/requirements.txt
```

Or from within each folder:

```bash
cd <folder>
pip install -r requirements.txt
```

---

## Running the Project

The project must be set up in the following order.

### 1. Provision Initial Infrastructure

```bash
cd terraform
terraform apply
```

This creates core AWS resources including **ECR repositories** for storing Docker images.

> Note: this first apply may fail on resources that depend on Docker images not yet pushed — this is expected. Continue to step 2.

---

### 2. Run the Historical Data Backfill

Populate the data lake with all historical records from the RDS:

```bash
cd pipeline/backfill
python backfill_extract.py
python backfill_transform.py
python backfill_load.py
```

---

### 3. Build and Push Docker Images

From each service folder, run the corresponding upload script to build and push the image to ECR:

```bash
# From pipeline/
sh upload_dockerfile_pipeline.sh

# From dashboard/
sh upload_dockerfile_dashboard.sh

# From report/
sh upload_dockerfile_report.sh
```

Each script:
1. Builds the Docker image
2. Tags it with the ECR repository URI
3. Pushes it to Amazon ECR

---

### 4. Complete Infrastructure Deployment

Run Terraform again to provision the remaining resources that depend on the container images:

```bash
cd terraform
terraform apply
```

This creates:
- **ECS task** — runs the ETL pipeline every 3 hours via EventBridge
- **AWS Lambda** — generates a daily HTML report at 09:30 AM
- **ECS service** — hosts the Streamlit dashboard

---

### 5. Run the Pipeline Locally (optional)

To run the ETL pipeline manually without Docker:

```bash
cd pipeline
python extract.py
python transform.py
python load.py
```

---

### 6. Run the Dashboard Locally (optional)

```bash
cd dashboard
streamlit run app.py
```

The dashboard will be available at `http://localhost:8501`.

---

## Additional Documentation

| Folder | README |
|---|---|
| `pipeline/` | ETL pipeline and backfill |
| `dashboard/` | Streamlit dashboard |
| `report/` | Daily Lambda report |
| `terraform/` | Infrastructure configuration |
