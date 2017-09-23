#!/bin/bash -
#title           :startup-execute.sh
#description     :This script will execute on boot-sequence and get config from server, then pass it to startup-parse.sh
#author		     :horovtom
#date            :1506032671
#version         :0.1
#usage		     :bash startup-execute.sh
#notes           :
#==============================================================================

#This is being overwriten by config file on GIT
logFile="/tmp/gpjp-startup.log"

function myEcho() {
    #FIXME: scriptLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    local scriptLocation="startup-execute.sh"
    if [ "$logFile" == "" ] ; then
        echo $scriptLocation": "$1 >> /tmp/hades-unconfigured.log
        echo $scriptLocation": "$1
    else
        echo $scriptLocation": "$1 >> $logFile
        echo $scriptLocation": "$1
    fi
}

function installMode() {
    myEcho "Installing: $1"
    sudo apt-get install $1 -y
}

function addToExecuted() {
    echo $1 >> /opt/gpjp-hades/executed.list
}

function alreadyExecuted() {
    grep -Fxq $1 /opt/gpjp-hades/executed.list 
    return $?
}

function singleMode() {
    myEcho "Singleing: $1"
    #Get first word (should be ID)
    local commandID=$( awk '{print $1}' <<< $1 )
    if ! [[ $commandID =~ ^-?[0-9]+$ ]] ; then
        myEcho "Wrong syntax for singleMode. Expected ID, got: $commandID"
        exit -2
    fi
    alreadyExecuted $commandID
    if [[ $? -ne 0 ]] ; then
        local commandToExec=$( echo $1 | cut -d " " -f2- )
        myEcho "Executing $commandToExec"
        sudo bash -c "$commandToExec"

        addToExecuted $commandID
    else
        myEcho "Command $commandID has been already executed on this machine"
    fi
}

function routineMode() {
    myEcho "Routining: $1 as $defaultUser"
    sudo su -c "bash -c \"$1\"" $defaultUser
}

function routineRootMode() {
    myEcho "Routining as root: $1"
    sudo bash -c "$1"
}

function loadConfig() {
    if [ ! -x /tmp/gpjp-hades/Scripts/gpjp-startup-cfg.sh ] ; then
        myEcho "Config not found! Maybe you deleted /tmp/gpjp-hades/Scripts ?"
        exit -1
    fi
    
    source /tmp/gpjp-hades/Scripts/gpjp-startup-cfg.sh
}

loadConfig

#Check number of args:
if [[ $# -ne 2 ]] ; then
    myEcho "ERROR: I got wrong number of args: $#"
    exit -1
fi

case "$1" in
    "I")
        installMode "$2"
    ;;
    "S")
        singleMode "$2"
    ;;
    "Rr")
        routineRootMode "$2"
    ;;
    "R")
        routineMode "$2"
    ;;
    *)
        myEcho "I don't know mode: $1, skipping"
    ;;
esac

myEcho "--Command Done--"
