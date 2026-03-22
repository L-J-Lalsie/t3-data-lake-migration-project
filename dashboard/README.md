# T3 Data Dashboard

## Overview

This dashboard provides an interactive **summary view of T3 food truck transaction data**.

It is built using **Streamlit** and displays key insights such as:

- Total revenue
- Average transaction value
- Transaction counts
- Truck-level performance metrics

The dashboard retrieves processed data from **AWS S3/Athena** and presents it in an easy-to-understand interface for monitoring food truck performance.

---

## Dependencies

All required Python dependencies are listed in the `requirements.txt` file.

Key dependencies include:

| Package | Purpose |
|---|---|
| streamlit | Dashboard UI framework |
| awswrangler | Querying data from S3/Athena |
| pandas | Data processing and aggregation |
| boto3 | AWS SDK for authentication and resource access |

Environment variables must be defined in a `.env` file located in the `dashboard/` folder.

---

## Environment Variables

Create a `.env` file in the **dashboard directory** with the following variables:

```

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=

````

These credentials allow the dashboard to securely access AWS resources.

---

## Running the Dashboard Locally

1. Navigate to the dashboard directory:

```bash
cd dashboard
````

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Start the Streamlit dashboard:

```bash
streamlit run app.py
```

The dashboard will open in your browser at:

```
http://localhost:8501
```

---

## Running the Dashboard with Docker

The dashboard can also be deployed as a **containerised service on AWS ECS**.

### 1. Apply Terraform Infrastructure

First, create the required AWS resources:

```bash
terraform apply
```

This step provisions infrastructure such as **ECR repositories and ECS services**.

---

### 2. Build and Push the Docker Image

From the dashboard folder, run the deployment script:

```bash
sh upload_dockerfile_dashboard.sh
```

This script:

1. Builds the Docker image
2. Tags it with the **ECR repository URI**
3. Pushes the image to **Amazon ECR**

---

### 3. Finalise Infrastructure Deployment

Run Terraform again to complete the service deployment:

```bash
terraform apply
```

The ECS service will now launch the container.

---

### 4. Access the Dashboard

Find the **public IP address** of the ECS service and open:

```
http://YOUR_PUBLIC_IP:8501
```

You should now see the **T3 Data Dashboard running in the browser**.

---

## Deployment Order

For a full deployment, follow this order:

```
terraform apply
sh upload_dockerfile_dashboard.sh
terraform apply
```

The first Terraform run creates **ECR repositories**, while the second completes the **ECS service deployment** after the Docker image has been uploaded.