# Install with Bash

```bash
sudo bash -c "bash <(curl -s https://raw.githubusercontent.com/gpjp-hades/Scripts/master/bootstrap.sh)"
```
### Uninstall
Sorry to see you go.
```bash
sudo bash -c "bash <(curl -s https://raw.githubusercontent.com/gpjp-hades/Scripts/master/uninstall.sh) -a"
```
# About
This is frontend for the **Hades** project

HADES is an update system for multiple Ubuntu-based Linux machines.

To install Hades to your computer, run ```bootstrap.sh``` as **root**.
To uninstall Hades from your computer, run ```uninstall.sh``` as **root**. 
If you want to **remove config files** alongside Hades, run ```uninstall.sh -a```

This section of the code handles local management and comunication with the server

  *Whe? -Ok...*

## Behind the scenes
* #### Modification of runlevels process

    If runlevels specified in ```/opt/gpjp-hades/gpjp-startup-cfg.sh``` 
do not match with actual runlevels, startup-updater script will 
replace links for ```startup.sh``` and ```startup.sh``` will replace links for
```startup-updater.sh```

* #### Modification of ```startup.sh``` or ```startup-updater.sh``` process:

    They will update each other, just as in the Modification of runlevels process.
startup-updater will ```update startup.sh``` to the one specified in ```/opt/gpjp-hades/```
