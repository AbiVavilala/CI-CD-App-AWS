#!/bin/bash

echo "This Script is used to stop already running docker container, remove them and remove the image as well"

#!/bin/bash

# Stop all running Docker containers
docker stop $(docker ps -aq)

# Remove all stopped containers
docker rm $(docker ps -aq)

# Remove all Docker images
docker rmi $(docker images -q)
