#!/bin/bash

yum update -y
yum install -y aws-cli

yum install -y docker
service docker start
systemctl enable docker
usermod -a -G docker ec2-user

curl -SL https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

yum install -y amazon-efs-utils
mkdir /home/ec2-user/efs
mount -t efs <efs-file-system-id>:/ /home/ec2-user/efs
echo "<efs-file-system-id>:/ /home/ec2-user/efs efs defaults,_netdev 0 0" >> /etc/fstab

mkdir /home/ec2-user/projeto-docker
cd /home/ec2-user/projeto-docker

cat > docker-compose.yml <<EOL
version: '3.7'
services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    environment:
      WORDPRESS_DB_HOST: <RDS-ENDPOINT>  
      WORDPRESS_DB_NAME: <db_name>       
      WORDPRESS_DB_USER: <db_user>       
      WORDPRESS_DB_PASSWORD: <db_password> 
    ports:
      - 80:80
    volumes:
      - /mnt/efs:/var/www/html

volumes:
  wordpress_data:
EOL

docker-compose up -d


