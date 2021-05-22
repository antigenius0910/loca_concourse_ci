#!/bin/bash

#set -x 

# Required parameters for running this script
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    echo "Usage : $0 <ARTIFACTORY_USER> <ARTIFACTORY_PASSWORD> <NEW_BUILD>"
    exit 1
fi

ARTIFACTORY_USER=$1
ARTIFACTORY_PASSWORD=$2
NEW_BUILD=$3

#echo $ARTIFACTORY_USER
#echo $ARTIFACTORY_PASSWORD
#echo $NEW_BUILD

cd /tmp
jfrog rt dl "example-repo-local/$NEW_BUILD.deb" --user=$ARTIFACTORY_USER --password=$ARTIFACTORY_PASSWORD --url=http://localhost:8082/artifactory 
mkdir /tmp/$NEW_BUILD
mv /tmp/$NEW_BUILD.deb /tmp/$NEW_BUILD
cd  /tmp/$NEW_BUILD
sudo dpkg-deb -R $NEW_BUILD.deb .
tree
cat /tmp/$NEW_BUILD/DEBIAN/control
cat /tmp/$NEW_BUILD/lib/systemd/system/test-agent.service
