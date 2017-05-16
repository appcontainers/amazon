cd base
docker build -t build/amazon .
docker run -it -d --name amazon build/amazon /bin/bash
docker export amazon | docker import - appcontainers/amazon:latest
docker tag appcontainers/amazon:latest appcontainers/amazon:2017.03
docker kill amazon; docker rm amazon
docker push appcontainers/amazon:latest
docker push appcontainers/amazon:2017.03
docker rmi build/amazon
docker rmi appcontainers/amazon:2017.03

cd ../ansible
docker build -t build/amazon .
docker run -it -d --name amazon build/amazon /bin/bash
docker export amazon | docker import - appcontainers/amazon:ansible
docker tag appcontainers/amazon:latest appcontainers/amazon:ansible-2017.03
docker kill amazon; docker rm amazon
docker push appcontainers/amazon:ansible
docker push appcontainers/amazon:ansible-2017.03
docker rmi build/amazon
docker rmi appcontainers/amazon:ansible-2017.03