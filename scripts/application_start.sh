echo "Running container..."
docker run --name flask_app -d -p 5000:5000 123456789.dkr.ecr.us-east-1.amazonaws.com/flask_image:latest