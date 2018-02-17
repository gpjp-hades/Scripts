This is part of a project: 
    SYSTEM HADES

HADES is an update system for multiple Ubuntu-based Linux machines.

To install HADES to your computer, run bootstrap.sh as root
To uninstall HADES from your computer, run uninstall.sh as root. 
If you want to uninstall config files as well, run uninstall.sh -a

This section of the code handles local management and comunication with the server




Modification of runlevels process:

If runlevels specified in /opt/gpjp-hades/gpjp-startup-cfg.sh 
do not match with actual runlevels, startup-updater script will 
replace links for startup.sh and startup.sh will replace links for
startup-updater.sh

Modification of startup.sh or startup-updater.sh process:

They will update each other, just as in the Modification of runlevels process.
startup-updater will update startup.sh to the one specified in /opt/gpjp-hades/