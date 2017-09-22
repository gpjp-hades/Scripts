#!/bin/bash -       
#title           :startup-updater.sh
#description     :This script will be executed on boot-sequence and update startup from git repository, modyfiyng runlevels if needed
#author		     :horovtom
#version         :0.1    
#notes           :
#==============================================================================

function myEcho() {
    scriptLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    if [ "$logFile" == "" ] ; then
        echo $scriptLocation": "$1 >> /tmp/gpjp-config-unconfigured.log
        echo $scriptLocation": "$1
    else
        echo $scriptLocation": "$1 >> $logFile
        echo $scriptLocation": "$1
    fi
}

#Does /opt/gpjp-config exist?
if [ ! -d /opt/gpjp-config ] ; then
    myEcho "/opt/gpjp-config not found!";
    exit -1;
fi