#!/bin/bash -       
#title           :gpjp-startup-cfg.sh
#description     :This script contains all the settings
#author		     :horovtom
#version         :0.1    
#notes           :This file should be located in /opt/gpjp-config/gpjp-startup-cfg.sh. If it is not there, scripts will download latest version from git
#==============================================================================

#########################
#   Global variables:   #
#########################

#Location of the repository
repository="git://github.com/keombre/gpjp-config.git"
#Local path to output log file
logFile="/tmp/gpjp-startup.log"

#########################
#   Startup variables:  #
#########################

runlevel=5
runPriority=90