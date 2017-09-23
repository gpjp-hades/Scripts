#!/bin/bash -
#title           :startup.sh
#description     :This script will be executed on boot-sequence and update startup-execute from git repository, then run it
#author		     :horovtom
#version         :0.2
#notes           :This script will take existing gpjp-config clone from gpjp-startup-updater.sh
#==============================================================================

configFilePath="gpjp-startup-cfg.sh"
#Location of the repository
repository="git://github.com/gpjp-hades/Scripts.git"
#This is being overwriten by config file on GIT
logFile="/tmp/gpjp-startup.log"

function myEcho() {
    #FIXME: scriptLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    scriptLocation="startup.sh"
    if [ "$logFile" == "" ] ; then
        echo $scriptLocation": "$1 >> /tmp/hades-unconfigured.log
        echo $scriptLocation": "$1
    else
        echo $scriptLocation": "$1 >> $logFile
        echo $scriptLocation": "$1
    fi
}

function waitForInternet() {
    myEcho "Waiting for internet:"
    count=100
    while ! ping -c 1 -W 1 8.8.8.8; do
        sleep 1
        count=$(($count - 1))
        if [ $count -lt 0 ] ; then
            myEcho "Could not connect to the internet! Update script terminating!"
            exit -1
        else
            myEcho "Pinging..."
        fi
    done
    myEcho "Connected!"
}

function loadConfig() {
    waitForInternet
    
    #Is git installed?
    if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        myEcho "Git not found, fixing: ";
        sudo apt-get install git -y;
    fi
    
    if [ -d /tmp/gpjp-hades ] ; then
    #Clean the directory:
    sudo rm -rf /tmp/gpjp-hades/Scripts
    else
    #Create the directory:
    sudo mkdir /tmp/gpjp-hades
    fi
    
    #Clone repository:
    git clone $repository /tmp/gpjp-hades/Scripts
    
    #Load config:
    if [ -x "/tmp/gpjp-hades/Scripts/"$configFilePath ]; then
        source /tmp/gpjp-hades/Scripts/$configFilePath;
        if [ ! -d /opt/gpjp-config ] ; then
            sudo mkdir /opt/gpjp-config
        fi
        cp /tmp/gpjp-hades/Scripts/$configFilePath /opt/gpjp-config/
        cp /tmp/gpjp-hades/Scripts/Startup-sequence/startup.sh /opt/gpjp-config
    else
        myEcho "Error: Config file not found!";
        exit -4;
    fi
}

function deleteUpdaterRunLinks() {
    sudo find /etc -type l -name '*gpjp-startup-updater.sh' -exec rm {} +
}

function createUpdaterRunLink() {
    myEcho "Creating updater RunLink at: "$1
    sudo ln -s /etc/init.d/gpjp-startup-updater.sh $1
    
    #Error check:
    if [ $? -ne 0 ]; then
        myEcho "There was an error while creating link!"
        exit -5
    fi
}

function updateRunlevels() {
    target="/etc/rc"$updaterRunlevel".d/S"$updaterRunPriority"gpjp-startup-updater.sh"
    myEcho "Target for update is: "$target
    if [ ! -L $target ] ; then
        myEcho "Something about RUN changed!"
        #Something about RUN changed!
        deleteUpdaterRunLinks
        createUpdaterRunLink $target
    else
        myEcho "Run has not been changed"
    fi
}

function updateScript() {
    cmp /etc/init.d/gpjp-startup-updater.sh /tmp/gpjp-hades/Scripts/Startup-sequence/startup-updater.sh -s
    if [ $? -ne 0 ] ; then
        sudo cp /tmp/gpjp-hades/Scripts/Startup-sequence/startup-updater.sh /etc/init.d/gpjp-startup-updater.sh
        myEcho "Loading new version of startup-updater.sh"
    else
        myEcho "startup-updater.sh is up to date"
    fi
    
    sudo chmod 755 /etc/init.d/gpjp-startup-updater.sh
}

function updateUpdater() {
    updateScript
    updateRunlevels
}

loadConfig

#Do runlevels of startup-updater differ from those in config?
updateUpdater

#Run startup parse script:
myEcho "Running parse script"
sudo /tmp/gpjp-hades/Scripts/Startup-sequence/startup-parse.sh

myEcho "Parse script returned: "$?
#FIXME: Wait for all async calls (Shouldn't be needed!)
sleep 10

#Clean up:
sudo rm -rf /tmp/gpjp-hades/Scripts