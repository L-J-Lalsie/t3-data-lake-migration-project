# Container Deployment Pipeline

## Overview
This setup deploys a containerised pipeline to AWS using **Docker, ECR, ECS, and EventBridge**.

- **Terraform** provisions the required AWS infrastructure.
- **Docker** builds the container image.
- **Amazon ECR** stores the container image.
- **Amazon ECS** runs the container task.
- **Amazon EventBridge** triggers the ECS task every **3 hours**.

---

## Architecture

1. Terraform provisions AWS resources.
2. Docker builds the application image.
3. The image is pushed to **Amazon ECR**.
4. **ECS** pulls the image and runs the container task.
5. **EventBridge** triggers the ECS task on a schedule.

---

## How to Deploy

### 1. Provision Infrastructure

Run Terraform to create the required AWS resources, including:

- ECR repository
- ECS task definition
- EventBridge scheduler
- Supporting IAM roles

**Be aware**: This will fail the first time but move onto step 2.

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

## Running the Pipeline

Once the image is pushed:

* **Amazon ECS** can pull the image from ECR.
* **EventBridge** automatically triggers the ECS task **every 3 hours**.
* The scheduling configuration is defined in the **Terraform infrastructure code**.

No manual execution is required after deployment.

---

## Summary

| Component   | Purpose                                |
| ----------- | -------------------------------------- |
| Terraform   | Infrastructure provisioning            |
| Docker      | Containerising the pipeline            |
| Amazon ECR  | Container image registry               |
| Amazon ECS  | Runs the container task                |
| EventBridge | Scheduled task trigger (every 3 hours) |
