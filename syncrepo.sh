#!/bin/bash
#This script assume you need to login to on premise quay.io and the other registery is docker-distribution
#you need to have podman installed 
#yum install -y podman
#you need to have jq installed
#wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
#chmod +x ./jq
#cp jq /usr/bin
sourceRegistry="quayio.myhost.com"
destinationRegistry="repo2.myhost.com:5000"
username=admin
password=Iahoora@123
limit=100

allImages=$(podman search $sourceRegistry/  --limit=$limit | awk '{print $2}' | tail -n+2)
for image in $allImages 
do
  repoUser=$(echo $image | awk -F/ '{print $2}')
  repoImage=$(echo $image | awk -F/ '{print $3}') 
  tags=$(curl -su $username:$password https://$sourceRegistry/v1/repositories/$repoUser/$repoImage/tags |  jq --args | sed -e 's/{*}*"*:*//g' | awk '{print $1}') 
  for tag in $tags 
  do 
    podman pull $image:$tag  
    podman tag $image:$tag $destinationRegistry/$repoUser/$repoImage:$tag  
    podman push $destinationRegistry/$repoUser/$repoImage:$tag  
  done 
done
