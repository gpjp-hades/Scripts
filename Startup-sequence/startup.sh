#!/bin/bash -       
#title           :startup.sh
#description     :This script will be executed on boot-sequence and update startup-execute from git repository, then run it
#author		     :horovtom
#version         :0.1    
#usage		     :bash startup.sh
#notes           :
#==============================================================================
source $(dirname $0)/../common-functions.sh

#We agreed that it is feasible to download whole repository every time
repository="git://github.com/keombre/gpjp-config.git"

#common-functions call
isGitInstalled

#Clean the directory:
sudo rm -rf /tmp/gpjp-config

#Clone repository:
git clone $repository /tmp/gpjp-config

#Run startup parse script:
echo "Running parse script" > /tmp/gpjp-startup.log
sudo /tmp/gpjp-config/Startup-sequence/startup-parse.sh

sleep 20

#Clean up:
sudo rm -rf /tmp/gpjp-config