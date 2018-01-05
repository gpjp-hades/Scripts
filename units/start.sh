#!/bin/bash

# install ansible
apt-get install ansible -y

# get UUID (somehow)
token=$( echo $( sudo dmidecode -t 4 | grep ID | sed 's/.*ID://;s/ //g' ) \
       | sha256sum | awk '{print $1}' )

# ask Hades for config
state=$(curl -sL $HADES/api/$token)

# check if we are approved (dirty but functional)
if [[ $state == *"approved"* ]]; then

    # get config name (also dirty..)
    config=$(grep -oP 'g": "\K.*?(?=")' <<< "$state").yml;

    # and start ansible
    ansible-pull -U $REPO -o $config;
else

    # print error message
    echo "Request failed; status: "$state
fi