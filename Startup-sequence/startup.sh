#!/bin/bash -       
#title           :startup.sh
#description     :This script will be executed on boot-sequence and update startup-execute from git repository, then run it
#author		     :horovtom
#version         :0.1    
#notes           :
#==============================================================================

configFilePath="gpjp-startup-cfg.sh"

#Is git installed?
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Git not found, fixing: ";
    sudo apt-get install git -y;
else
    echo "Git found!";
fi

#Clean the directory:
sudo rm -rf /tmp/gpjp-config

#Clone repository:
git clone $repository /tmp/gpjp-config

#Load config:
echo "Loading config file..."
if [ -x /tmp/gpjp-config/$configFilePath ]; then
    /tmp/gpjp-config/$configFilePath;
else
    echo "Error: Config file not found!" > /tmp/gpjp-config-error.log;
    exit -4;
fi

#Run startup parse script:
echo "startup.sh: Running parse script" > $logFile
sudo /tmp/gpjp-config/Startup-sequence/startup-parse.sh

echo "startup.sh: Parse script returned: "$? > $logFile
#FIXME: Wait for all async calls (Shouldn't be needed!)
sleep 10

#Clean up:
sudo rm -rf /tmp/gpjp-config