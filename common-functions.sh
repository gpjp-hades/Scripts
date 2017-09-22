#!/bin/bash -
#title           :common-functions.sh
#description     :This script is in fact a library with commonly used functions for all the other scripts in this repository
#author		     :horovtom
#version         :0.1
#==============================================================================

function isGitInstalled() {
    if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        echo "Git not found, fixing: ";
        sudo apt-get install git -y;
    else
        echo "Git found!";
    fi
}