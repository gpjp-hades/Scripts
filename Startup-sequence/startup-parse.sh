#!/bin/bash -
#title           :startup-parse.sh
#description     :This script will parse config file and carry out it's orders.
#author		     :horovtom
#version         :0.1
#usage		     :bash startup-parse.sh
#notes           :
#==============================================================================

name=""
#This is being overwriten by config file on GIT
logFile="/tmp/gpjp-startup.log"


function myEcho() {
    #FIXME: scriptLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    scriptLocation="startup-parse.sh"
    if [ "$logFile" == "" ] ; then
        echo $scriptLocation": "$1 >> /tmp/hades-unconfigured.log
        echo $scriptLocation": "$1
    else
        echo $scriptLocation": "$1 >> $logFile
        echo $scriptLocation": "$1
    fi
}

function loadConfig() {
    if [ ! -x /tmp/gpjp-hades/Scripts/gpjp-startup-cfg.sh ] ; then
        myEcho "Config not found! Maybe you deleted /tmp/gpjp-hades/Scripts ?"
        exit -1
    fi
    
    source /tmp/gpjp-hades/Scripts/gpjp-startup-cfg.sh
}

function downloadInstructionsLoaction() {
    if [ ! -x /opt/gpjp-hades/localSettings.sh ] ; then
        myEcho "Could not find local config so passing empty name!"
    else
        source /opt/gpjp-hades/localSettings.sh
    fi
    
    name="${name//' '/%20}"
    
    myToken=$( echo $( sudo dmidecode -t 4 | grep ID | sed 's/.*ID://;s/ //g' ) \
    | sha256sum | awk '{print $1}' )
    
    #myEcho "Name is: "$name
    
    request=$serverAddress"/api/"$myToken"/"$name
    
    #myEcho "My token is: $myToken"
    myEcho "Sending request: $request"
    
    response=$( curl -s $request --silent )
    
    if [ "$response" == "" ] ; then
        myEcho "There has been an error communicating with the server! Trying the old standard request: "
        request=$serverAddress"/api.php?token="$myToken"&name="$name
        myEcho "Sending request: $request"
        response=$( curl -s $request --silent )
        if [ "$response" == "" ] ; then
            myEcho "ERROR server unreachable!"
            exit -1
        fi
    fi
    
    myEcho "Response was: $response"
    
    result=$( echo $response | python -c 'import sys, json; print json.load(sys.stdin)["result"]' )
    
    #Is it the first time it has registered?
    if [ "$result" == "request pending" ] ; then
        myEcho "Nothing to do! Waiting for admin to approve this machine in system"
        exit 1
        elif [ "$result" == "approved" ] ; then
        config=$( echo $response | python -c 'import sys, json; print json.load(sys.stdin)["config"]' )
        eval "$1='$config'"
        return
        elif [ "$result" == "invalid request" ] ; then
        myEcho "ERROR: Server did not approve this request! This machine may be doomed!!!! Response was: $response"
        exit -1
    else
        myEcho "ERROR: There has been an error communicating with the server! Response was: $response"
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
    return
}

function downloadInstructions() {
    #Is repository set up?
    git -C /opt/gpjp-hades/Instructions rev-parse
    if [ $? -ne 0 ] ; then
        sudo git clone http://github.com/gpjp-hades/Instructions /opt/gpjp-hades/
        git -C /opt/gpjp-hades/Instructions rev-parse
        if [ $? -ne 0 ] ; then
            myEcho "ERROR: An error occurred while downloading Instructions repository!"
            exit -100
        fi
    fi
    
    #Is it up to date?
    git fetch --all
    git reset --hard origin/master
    
    if [ ! -f /opt/gpjp-hades/$instructionsLocation ] ; then
        myEcho "ERROR: Instructions repository does not contain instructions file: $instructionsLocation"
        exit -4
    fi
}

loadConfig
instructionsLocation=""
downloadInstructionsLoaction instructionsLocation
myEcho "Instructions location is: $instructionsLocation"
downloadInstructions $instructionsLocation
parseInstructions $instructionsLocation