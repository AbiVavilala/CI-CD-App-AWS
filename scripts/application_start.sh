echo "Running container..."
docker run --name flask_app -d -p 5000:5000 642655931180.dkr.ecr.ap-southeast-2.amazonaws.com/flask_image:latest