#!/usr/bin/env bash
#title           :hadesCommand.sh
#description     :This script is run when hades or gpjp-hades commands are run at target system
#author		     :horovtom
#version         :0.2
#usage		     :hades or gpjp-hades
#notes           :
#=============================================================================
set -o errexit
source /opt/gpjp-hades/localSettings.sh

if [ "$#" -eq 0 ] ; then
    echo "Gpjp-Hades application. 
    Name = $name
    defaultUser = $defaultUser"   
    exit 0
fi

if [ "$1" == "-h"] || [ "$1" == "--help"] ; then
    echo "Usage: $0 [-h/--help/-u/--update]" 
    exit 0
fi

if [ "$1" == "-u"] || [ "$1" == "--update"] ; then
    echo "Updating!"
    if [ "$EUID" -ne 0 ] ; then
        echo "ERROR: Please run this script as root!!"
        exit -10
    fi
    sudo /etc/init.d/gpjp-startup.sh
    echo "Done!"
    exit 0
fi

echo "Unknown parameter $1! Run $0 -h for help."
exit -1