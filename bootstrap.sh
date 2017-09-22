#!/bin/bash -       
#title           :bootstrap.sh
#description     :This script will install startup script into boot sequence of a system.
#author		     :horovtom
#version         :0.1    
#usage		     :bash bootstrap.sh
#notes           :Needs the structure of startup repository: gpjp-startup/Startup-sequence
#==============================================================================

runlevel=5
runPriority=90

#Download startup.sh from some server (GIT? Our server?) 
#I assume it will be on git:
{
sudo apt-get install git -y
} &> /dev/null
#Curl way:
#startupRepository="https://codeload.github.com/keombre/gpjp-config/zip/master"
#curl -L $startupRepository> /tmp/startupRepository.zip
#Git way:
startupRepository="git://github.com/keombre/gpjp-config.git"
#Clean the directory:
sudo rm -rf /tmp/gpjp-startup
#Clone repository:
git clone $startupRepository /tmp/gpjp-startup
#Error check:
if [ $? -ne 0 ]; then
    echo "There was an error while cloning repository!"
    exit -1
fi

echo "Copying startup script to: /etc/init.d/gpjp-startup.sh"
sudo cp /tmp/gpjp-startup/Startup-sequence/startup.sh /etc/init.d/gpjp-startup.sh
sudo chmod 755 /etc/init.d/gpjp-startup.sh

if [ $? -ne 0 ]; then
    echo "There was an error while copying startup script to /etc/init.d"
    exit -2
fi

target="/etc/rc"$runlevel".d/S"$runPriority"gpjp-startup.sh"
#Clean up any previously set symlink:
sudo rm -f $target
#Create symlink to runlevel
echo "Creating symlink at: "$target
sudo ln -s /etc/init.d/gpjp-startup.sh $target

if [ $? -ne 0 ]; then
    echo "There was an error while creating link!"
    exit -3
fi

echo "Startup script all set!"
echo "Cleaning up:"
sudo rm -rf /tmp/gpjp-config