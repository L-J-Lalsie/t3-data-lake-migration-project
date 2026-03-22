# Step 1: Authenticate Docker to ECR
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 129033205317.dkr.ecr.eu-west-2.amazonaws.com

# Step 2: Build your Docker image
docker buildx build --platform linux/amd64 --provenance=false -t t3-report .

# Step 3: Tag your Docker image
docker tag t3-report:latest 129033205317.dkr.ecr.eu-west-2.amazonaws.com/c22-lance-t3-report-ecr:latest

# Step 4: Push the image to ECR
docker push 129033205317.dkr.ecr.eu-west-2.amazonaws.com/c22-lance-t3-report-ecr:latest