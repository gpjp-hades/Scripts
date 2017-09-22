#!/bin/bash -       
#title           :bootstrap.sh
#description     :This script will install startup script into boot sequence of a system.
#author		     :horovtom
#version         :0.1    
#usage		     :bash bootstrap.sh
#notes           :
#==============================================================================

#Download startup.sh from some server (GIT? Our server?) 
#I assume it will be on git:
sudo apt-get install git -y
#Curl way:
#startupRepository="https://codeload.github.com/keombre/gpjp-config/zip/master"
#curl -L $startupRepository> /tmp/startupRepository.zip
#Git way:
startupRepository="git://github.com/keombre/gpjp-config.git"
sudo rm -rf /tmp/gpjp-startup
git clone $startupRepository /tmp/gpjp-startup

if [ $? -ne 0 ]; then
    echo "There was an error while cloning repository!"
    exit -1
fi

sudo cp /tmp/gpjp-startup/startup-sequence/startup.sh /etc/init.d/gpjp-startup.sh
sudo chmod 755 /etc/init.d/gpjp-startup.sh