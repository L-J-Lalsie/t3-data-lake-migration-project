# Lambda Report Generator

## Overview

This AWS Lambda function generates a **daily summary report for T3 transaction data**.

Every morning at **09:30 AM**, the Lambda function:

1. Queries **yesterday’s transaction data**.
2. Calculates summary metrics.
3. Generates an **HTML report**.
4. Uploads the report to **Amazon S3**.

The report provides a quick overview of sales performance across all **T3 food trucks**.

---

## Requirements

Dependencies are pinned in `requirements.txt` to ensure **consistent builds and compatibility** inside the Lambda Docker container.

| Package | Version | Purpose |
|---|---|---|
| numpy | `<2` | Required dependency for PyArrow |
| pyarrow | `14.0.1` | Used by awswrangler for reading Parquet data from S3 |
| awswrangler | latest | Extracts and queries data from S3/Athena |
| boto3 | latest | Uploads the generated HTML report to S3 |

Pinning versions prevents **dependency conflicts and runtime failures**, especially in Lambda environments where binary packages like **PyArrow** must match compatible **NumPy versions**.

---

## How to Deploy

Infrastructure and container deployment are managed with **Terraform and Docker**.

### 1. Provision AWS Resources

Run Terraform to create the required infrastructure:

- Lambda function
- EventBridge schedule
- IAM roles
- Supporting resources

```
terraform apply
````

---

### 2. Build and Push the Docker Image

Use the deployment script to build the container image and upload it to **Amazon ECR**.

```
sh upload_dockerfile_report.sh
```

This script:

1. Builds the Docker image
2. Tags it with the **ECR repository URI**
3. Pushes the image to **Amazon ECR**

Once pushed, the Lambda function can pull the image and execute the report script.

---

### 3. Complete AWS Resources

Run Terraform to create the rest of the resources now that it can reference an image.

```
terraform apply
````

---

## How to Test

You can manually trigger the Lambda function from the AWS Console.

1. Navigate to **AWS Lambda**
2. Select the **report generation Lambda**
3. Click **Test**
4. Run the function

After execution:

* Check the **S3 reports folder** for the generated report.
* If the report is not visible, inspect the **Lambda CloudWatch logs** for output or errors.

---

## Outputs

The generated HTML report is saved to the following location:

```
s3://c22-lance-s3-bucket/reports/daily_report_YYYY-MM-DD.html
```

Example:

```
s3://c22-lance-s3-bucket/reports/daily_report_2026-03-11.html
```

The report includes:

* **Total revenue**
* **Average transaction value**
* **Total transaction count**
* **Per-truck performance metrics**

This provides a **daily operational summary of T3 food truck activity**.