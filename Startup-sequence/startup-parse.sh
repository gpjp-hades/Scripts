#!/bin/bash -       
#title           :startup-parse.sh
#description     :This script will parse config file and carry out it's orders.
#author		     :horovtom
#version         :0.1    
#usage		     :bash startup-parse.sh
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

function loadConfig() {
    if [ ! -x /tmp/gpjp-config/gpjp-startup-cfg.sh ] ; then
        myEcho "Config not found! Maybe you deleted /tmp/gpjp-config ?"
        exit -1
    fi

    source /tmp/gpjp-config/gpjp-startup-cfg.sh

    if [ ! -x /tmp/gpjp-config/localSettings.sh ] ; then
        myEcho "Could not find local config so passing empty name!"
        name=""
    else
        source /tmp/gpjp-config/localSettings.sh
    fi

    name="${name//' '/%20}"

    request=$serverAddress"/api.php?token="$myToken"&name="$name
    
    myEcho "My token is: $myToken"
    myEcho "Sending request: $request"

    response=$(curl $request)
    myEcho "Response was: "$response
}

function downloadInstructions() {
    myToken=$( echo $( sudo dmidecode -t 4 | grep ID | sed 's/.*ID://;s/ //g' ) \
    | sha256sum | awk '{print $1}' )

}


loadConfig
instructions=""
downloadInstructions instructions
myEcho "Instructions are: "$instructions