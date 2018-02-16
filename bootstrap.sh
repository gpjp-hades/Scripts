#!/usr/bin/env bash
#title           :bootstrap.sh
#description     :This script will install startup script into boot sequence of a system.
#author		     :horovtom, keombre
#version         :0.2
#usage		     :bash bootstrap.sh
#notes           :Needs the structure of startup repository: gpjp-startup/Startup-sequence, gpjp-startup/systemd
#=============================================================================

function checkSudo() {
    if [ "$EUID" -ne 0 ] ; then
        echo "ERROR: Please run this script as root!!"
        exit -10
    fi
}

function welcome() {
    echo "  _    _           _           "
    echo " | |  | |         | |          "
    echo " | |__| | __ _  __| | ___  ___ "
    echo " |  __  |/ _\` |/ _\` |/ _ \\/ __|"
    echo " | |  | | (_| | (_| |  __/\\__ \\"
    echo " |_|  |_|\\__,_|\\__,_|\\___||___/"
    echo
    echo "Welcome to the HADES system installation!"
    echo
    printf "Do you want to proceede with the instalation? [Y/n]: "
    read -n 1 -r
    echo 
    if [[ $REPLY =~ (^[Yy]$|^$) ]]
    then
        echo "Alright, let's do it!"
        return 1
    else
        echo "Stopping!"
        return 0
    fi
}

startupRepository="git://github.com/gpjp-hades/Scripts.git"
configFilePath="gpjp-startup-cfg.sh"

function setupLinks() {
    target="/etc/rc"$runlevel".d/S"$runPriority"gpjp-startup.sh"
    #Clean up any previously set symlink:
    sudo rm -f $target
    
    #Create symlink to runlevel
    echo "Creating symlink at: "$target
    sudo ln -s /etc/init.d/gpjp-startup.sh $target
    
    #Error check:
    if [ $? -ne 0 ]; then
        echo "There was an error while creating link!"
        exit -3
    fi
    
    updaterTarget="/etc/rc"$updaterRunlevel".d/S"$updaterRunPriority"gpjp-startup-updater.sh"
    #Clean up any previously set symlink:
    sudo rm -f $updaterTarget
    
    #Create symlink to runlevel
    echo "Creating symlink at: "$updaterTarget
    sudo ln -s /etc/init.d/gpjp-startup-updater.sh $updaterTarget
    
    #Error check:
    if [ $? -ne 0 ]; then
        echo "There was an error while creating link!"
        exit -5
    fi
}

function copyScripts() {
    echo "Copying startup scripts to: /opt/gpjp-hades/"
    #sudo cp /tmp/gpjp-startup/Startup-sequence/startup.sh /etc/init.d/gpjp-startup.sh
    
    #sudo chmod 755 /etc/init.d/gpjp-startup.sh
    #sudo cp /tmp/gpjp-startup/Startup-sequence/startup-updater.sh /etc/init.d/gpjp-startup-updater.sh
    #sudo chmod 755 /etc/init.d/gpjp-startup-updater.sh

    sudo mkdir /opt/gpjp-hades/

    cp /tmp/gpjp-startup/Startup-sequence/startup.sh /opt/gpjp-hades/main
    cp /tmp/gpjp-startup/Startup-sequence/startup-updater.sh /opt/gpjp-hades/update
    
    #Error check:
    if [ ! -x /opt/gpjp-hades/main ] || [ ! -x /opt/gpjp-hades/update ] ; then
        echo "There was an error while copying startup scripts to /opt/gpjp-hades"
        exit -2
    fi
}

function loadConfig() {
    #Is git installed?
    if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        echo "Git not found, fixing: ";
        sudo apt-get install git -y;
    else
        echo "Git found!";
    fi
    
    #Clean the directory:
    sudo rm -rf /tmp/gpjp-startup
    
    #Clone repository (read-only):
    git clone $startupRepository /tmp/gpjp-startup
    
    #Whitespace:
    printf "\n\n";
    
    #Error check:
    if [ $? -ne 0 ]; then
        echo "There was an error while cloning repository!"
        exit -1
    fi
    
    
    #Load config:
    echo "Loading config file..."
    if [ -x "/tmp/gpjp-startup/"$configFilePath ]; then
        source /tmp/gpjp-startup/$configFilePath;
        echo "Config file loaded!";
    else
        echo "Error: Config file not found!";
        exit -4;
    fi
}

function setName() {
    if [ -x /opt/gpjp-hades/localSettings.sh ] ; then
        source /opt/gpjp-hades/localSettings.sh
        echo "Name of this machine is: $name"
        echo "Default user is: $defaultUser"
        return
    fi


    if [ $# -lt 1 ] ; then
        printf "Enter name for this PC [%s]: " $(hostname)
        read -r
        if [[ $REPLY == "" ]]
        then
            name=$(hostname)
        else
            name=$REPLY
        fi
    else
        name=$1
    fi

    echo "Name is: "$name
    echo "Default user is: $SUDO_USER"
    if [ ! -d /opt/gpjp-hades ] ; then
        sudo mkdir /opt/gpjp-hades
    fi
    
    if [ ! -f /opt/gpjp-hades/localSettings.sh ] ; then
        sudo echo "name=\"$name\"" > /opt/gpjp-hades/localSettings.sh
        sudo echo "defaultUser=\"$SUDO_USER\"" >> /opt/gpjp-hades/localSettings.sh
    fi
    
    if [ ! -x /opt/gpjp-hades/localSettings.sh ] ; then
        sudo chmod 755 /opt/gpjp-hades/localSettings.sh
    fi
}

function createCommands() {
    sudo cp /tmp/gpjp-startup/hadesCommand.sh /usr/bin/hades
    sudo rm -f /usr/bin/gpjp-hades
    sudo ln /usr/bin/hades /usr/bin/gpjp-hades
}

function systemdRegister() {
    sudo cp /tmp/gpjp-startup/systemd/hades.service /lib/systemd/system/
    sudo cp /tmp/gpjp-startup/systemd/hades.timer /lib/systemd/system/
    
    printf "Do you want Hades to start automatically? [Y/n]: "
    read -n 1 -r
    echo
    if [[ $REPLY =~ (^[Yy]$|^$) ]]
    then
        echo "Registering Hades with systemd..."
        sudo systemctl enable hades.timer
    fi
}

function startService() {
    echo "Starting Hades..."
    sudo systemctl daemon-reload
    sudo systemctl start hades.timer
}

function cleanUp() {
    echo
    echo "Startup script all set!"
    echo "Cleaning up..."
    sudo rm -rf /tmp/gpjp-startup
}


checkSudo
if welcome
then
    exit 0
fi

loadConfig
copyScripts
systemdRegister
setName
createCommands
cleanUp
startService