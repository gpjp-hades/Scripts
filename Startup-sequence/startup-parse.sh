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