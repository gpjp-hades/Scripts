#!/bin/bash -
#title           :startup-parse.sh
#description     :This script will parse config file and carry out it's orders.
#author		     :horovtom
#version         :0.1
#usage		     :bash startup-parse.sh
#notes           :
#==============================================================================

name=""
logFile="/tmp/gpjp-startup.log"


function myEcho() {
    
    #FIXME: scriptLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    scriptLocation="startup-parse.sh"
    if [ "$logFile" == "" ] ; then
        echo $scriptLocation": "$1 >> /tmp/gpjp-config-unconfigured.log
        echo $scriptLocation": "$1
    else
        echo $scriptLocation": "$1 >> $logFile
        echo $scriptLocation": "$1
    fi
}

function loadConfig() {
    if [ ! -x /tmp/gpjp-config/gpjp-startup-cfg.sh ] ; then
        myEcho "Config not found! Maybe you deleted /tmp/gpjp-config ?"
        exit -1
    fi
    
    source /tmp/gpjp-config/gpjp-startup-cfg.sh
}

function downloadInstructions() {
    if [ ! -x /opt/gpjp-config/localSettings.sh ] ; then
        myEcho "Could not find local config so passing empty name!"
    else
        source /opt/gpjp-config/localSettings.sh
    fi
    
    name="${name//' '/%20}"
    
    myToken=$( echo $( sudo dmidecode -t 4 | grep ID | sed 's/.*ID://;s/ //g' ) \
    | sha256sum | awk '{print $1}' )
    
    #myEcho "Name is: "$name
    
    request=$serverAddress"/api.php?token="$myToken"&name="$name
    
    #myEcho "My token is: $myToken"
    myEcho "Sending request: $request"
    
    response=$( curl -s $request --silent )
    myEcho "Response was: $response"
    
    firstField=$( echo $response | python -c 'import sys, json; print json.load(sys.stdin)["success"]' )
    
    #Is it the first time it has registered?
    if [ "$firstField" == "request pending" ] ; then
        myEcho "Nothing to do! Waiting for admin to approve this machine in system"
        exit 1
        elif [ "$firstField" == "approved" ] ; then
        config=$( echo $response | python -c 'import sys, json; print json.load(sys.stdin)["config"]' )
        eval "$1='$config'"
        return
        elif [ "$firstField" == "invalid request" ] ; then
        myEcho "Server did not approve this request! This machine may be doomed!!!! Response was: $response"
        exit -1
    else
        myEcho "There has been an error communicating with the server! Response was: $response"
        exit -2
    fi
}

function parseInstructions() {
    #Instructions are saved in $1
    
    #TODO: COMPLETE!
    
    #I think that one-time carry out instructions should be labeled by ID... This ID will be timeStamp of creation of command. Each computer will hold a list of ID's that it had carried out already. Any new one will be carried out.
    #This allows admin to enter one-time carry out instruction multiple times, even after it had been carried out.
    #We will probably need an application to manage these config files, so user does not have to add timestamp by hand every time.
    #time in seconds since epoch will be used as an timestamp. Command to get this in bash is:
    # date +%s
}

loadConfig
instructions=""
downloadInstructions instructions
myEcho "Instructions are: $instructions"
parseInstructions instructions