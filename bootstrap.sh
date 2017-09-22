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
startupRepository="git://github.com/keombre/gpjp-config.git"

#Is git installed?
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Git not found, fixing: ";
    sudo apt-get install git -y;
else
    echo "Git found!";
fi

#Clean the directory:
sudo rm -rf /tmp/gpjp-startup

#Clone repository:
git clone $startupRepository /tmp/gpjp-startup

#Whitespace:
printf "\n\n";

#Error check:
if [ $? -ne 0 ]; then
    echo "There was an error while cloning repository!"
    exit -1
fi

echo "Copying startup script to: /etc/init.d/gpjp-startup.sh"
sudo cp /tmp/gpjp-startup/Startup-sequence/startup.sh /etc/init.d/gpjp-startup.sh
sudo chmod 755 /etc/init.d/gpjp-startup.sh

#Error check:
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

#Error check:
if [ $? -ne 0 ]; then
    echo "There was an error while creating link!"
    exit -3
fi

echo "Startup script all set!"
echo "Cleaning up:"
sudo rm -rf /tmp/gpjp-config