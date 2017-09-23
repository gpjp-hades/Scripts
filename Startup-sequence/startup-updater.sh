#!/bin/bash -
#title           :startup-updater.sh
#description     :This script will be executed on boot-sequence and update startup from git repository, modyfiyng runlevels if needed
#author		     :horovtom
#version         :0.2
#notes           :
#==============================================================================

#This is being overwriten by config file on GIT
logFile="/tmp/gpjp-startup.log"

function myEcho() {
    #FIXME: scriptLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    scriptLocation="startup-updater.sh"
    if [ "$logFile" == "" ] ; then
        echo $scriptLocation": "$1 >> /tmp/hades-unconfigured.log
        echo $scriptLocation": "$1
    else
        echo $scriptLocation": "$1 >> $logFile
        echo $scriptLocation": "$1
    fi
}

function deleteRunLinks() {
    sudo find /etc -type l -name '*gpjp-startup.sh' -exec rm {} +
}

function createRunLink() {
    myEcho "Creating RunLink at: "$1
    sudo ln -s /etc/init.d/gpjp-startup.sh $1
    
    #Error check:
    if [ $? -ne 0 ]; then
        myEcho "There was an error while creating link!"
        exit -5
    fi
}

function updateRunlevels() {
    target="/etc/rc"$runlevel".d/S"$runPriority"gpjp-startup.sh"
    myEcho "Target for update is: "$target
    if [ ! -L $target ] ; then
        myEcho "Something about RUN changed!"
        #Something about RUN changed!
        deleteRunLinks
        createRunLink $target
    else
        myEcho "Run has not been changed"
    fi
}

function updateScript() {
    cmp /etc/init.d/gpjp-startup.sh /opt/gpjp-config/startup.sh -s
    if [ $? -ne 0 ] ; then
        sudo cp /opt/gpjp-config/startup.sh /etc/init.d/gpjp-startup.sh
        myEcho "Loading new version of startup.sh"
    else
        myEcho "startup.sh is up to date"
    fi
    
    sudo chmod 755 /etc/init.d/gpjp-startup.sh
}

function updateStartup() {
    #Does /opt/gpjp-config/startup.sh exist?
    if [ -x /opt/gpjp-config/startup.sh ] ; then
        updateScript
    else
        myEcho "Script is not present!"
    fi
    #Does config file exist?
    if [ -x /opt/gpjp-config/gpjp-startup-cfg.sh ] ; then
        source /opt/gpjp-config/gpjp-startup-cfg.sh
        updateRunlevels
    else
        myEcho "Config file is not present!"
    fi
}

#Does /opt/gpjp-config exist?
if [ ! -d /opt/gpjp-config ] ; then
    myEcho "/opt/gpjp-config not found!";
    exit -1;
fi

updateStartup

