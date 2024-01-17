#!/bin/bash

echo "Logging in to Amazon ECR..."
docker login --username AWS --password $(aws ecr get-login-password --region us-east-1) 642655931180.dkr.ecr.ap-southeast-2.amazonaws.com/flask_image
echo "Logged in to Amazon ECR successfully."

echo "Pulling image from Amazon ECR"
docker pull 642655931180.dkr.ecr.ap-southeast-2.amazonaws.com/flask_image:latest
echo "Pulled image from Amazon ECR successfully."