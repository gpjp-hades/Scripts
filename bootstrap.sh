#!/bin/bash -
#title           :bootstrap.sh
#description     :This script will install startup script into boot sequence of a system.
#author		     :horovtom
#version         :0.2
#usage		     :bash bootstrap.sh
#notes           :Needs the structure of startup repository: gpjp-startup/Startup-sequence
#=============================================================================

if [ "$EUID" -ne 0 ] ; then
    echo "ERROR: Please run this script as root!!"
    exit -10
fi

echo "Welcome to the HADES system installation, do you really want to install HADES and it's components? (Y/N)"
read result
if [ "$result" == "Y" ] || [ "$result" == "y" ] ; then
    echo "Alright, let's do it!"
else
    echo "Stopping!"
    exit 0
fi

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
    echo "Copying startup scripts to: /etc/init.d/"
    sudo cp /tmp/gpjp-startup/Startup-sequence/startup.sh /etc/init.d/gpjp-startup.sh
    sudo chmod 755 /etc/init.d/gpjp-startup.sh
    sudo cp /tmp/gpjp-startup/Startup-sequence/startup-updater.sh /etc/init.d/gpjp-startup-updater.sh
    sudo chmod 755 /etc/init.d/gpjp-startup-updater.sh
    
    #Error check:
    if [ ! -x /etc/init.d/gpjp-startup.sh ] || [ ! -x /etc/init.d/gpjp-startup-updater.sh ] ; then
        echo "There was an error while copying startup scripts to /etc/init.d"
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
        echo "Enter name for this PC:"
        read name
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

loadConfig
copyScripts
setupLinks
setName

echo "Startup script all set!"
echo "Cleaning up..."
sudo rm -rf /tmp/gpjp-startup
echo "DONE!"
