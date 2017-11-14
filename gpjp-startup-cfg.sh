#!/usr/bin/env bash
#title           :gpjp-startup-cfg.sh
#description     :This script contains all the settings
#author		     :horovtom
#version         :0.1
#notes           :This file should be located in /opt/gpjp-hades/gpjp-startup-cfg.sh. If it is not there, scripts will download latest version from git
#==============================================================================

#########################
#   Global variables:   #
#########################


#Local path to output log file
logFile="/tmp/HADES.log"

#########################
#   Startup variables:  #
#########################

# 1 < updaterRunLevel < $runlevel
updaterRunlevel=4
updaterRunPriority=90
# updaterRunlevel < runlevel < 6
runlevel=5
runPriority=90

serverAddress="keombre.carek.eu/hades/"