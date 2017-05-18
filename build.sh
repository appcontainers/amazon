# This build script will create the docker images for the Amazon Linux Base Image
# 2 Images will be created, one bare, and the other including Ansible
# Both images will contain the AWS CLI

# CD into the Main Project directory before launching this script

# Base Container Image
cd base
docker build -t build/amazon .
docker run -it -d --name amazon build/amazon /bin/bash
docker export amazon | docker import - appcontainers/amazon:latest
docker tag "appcontainers/amazon:latest" "appcontainers/amazon:2017.03"
docker kill amazon; docker rm amazon
docker push "appcontainers/amazon:latest"
docker push "appcontainers/amazon:2017.03"
docker images
docker rmi build/amazon
docker rmi "appcontainers/amazon:2017.03"

# Base Container Image with Ansible
cd ../ansible
docker build -t build/amazon .
docker run -it -d --name amazon build/amazon /bin/bash
docker export amazon | docker import - appcontainers/amazon:ansible
docker tag "appcontainers/amazon:latest" "appcontainers/amazon:ansible-2017.03"
docker kill amazon; docker rm amazon
docker push "appcontainers/amazon:ansible"
docker push "appcontainers/amazon:ansible-2017.03"
docker images
docker rmi build/amazon
docker rmi "appcontainers/amazon:ansible-2017.03"
