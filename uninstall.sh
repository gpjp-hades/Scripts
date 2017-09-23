#!/bin/bash -
#title           :uninstall.sh
#description     :This script will uninstall HADES system from computer.
#author		     :horovtom
#version         :0.1
#usage		     :bash uninstall.sh [-a]
#notes           :-a switch will delete all local user settings
#=============================================================================

if [ "$EUID" -ne 0 ] ; then
    echo "ERROR: Please run this script as root!!"
    exit -10
fi

function deinstall() {
    #Remove links:
    sudo find /etc -type l -name '*gpjp-startup-updater.sh' -exec rm {} +
    sudo find /etc -type l -name '*gpjp-startup.sh' -exec rm {} +
    
    #Remove scripts:
    sudo rm -f /etc/init.d/gpjp*
    
    echo "DONE!"
    exit 0
}

function removeAll() {
    echo "All right, let's do it!"
    sudo rm -rf /opt/gpjp-hades
    deinstall
}

function removePart() {
    echo "All right, let's do it!"
    sudo find /opt/gpjp-hades/ -not -name 'localSettings.sh' -type f -exec rm {} +
    deinstall
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
    echo "This script will delete HADES system from this computer. Use switch -a to delete all the files, if not specified, script will leave out local settings."
    exit 0
fi

if [ "$1" == "-a" ] ; then
    echo "Are you sure you want to uninstall HADES and all of it's components? (Y/N)"
    read result
    if [ "$result" == "Y" ] || [ "$result" == "y" ] ; then
        removeAll
    fi
    elif [ $# -eq 0 ] ; then
    echo "Are you sure you want to uninstall HADES, but leave config files? (Y/N)"
    read result
    if [ "$result" == "Y" ] || [ "$result" == "y" ] ; then
        removePart
    fi
else
    echo "Unrecognized parameters! Use -h to get help."
    exit -1
fi

echo "Cancelled"
exit 1
