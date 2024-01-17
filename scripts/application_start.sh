#!/bin/bash

# Authenticate Docker with ECR
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin 642655931180.dkr.ecr.ap-southeast-2.amazonaws.com

# Run the Docker container
docker run -d -p 80:80 642655931180.dkr.ecr.ap-southeast-2.amazonaws.com/flask_image:latest
