#!/bin/bash

# start adb allowing remote access by "-a" arg

# https://github.com/sorccu/docker-adb
# 2016-07-02 Due to internal ADB changes our previous start command no longer works in the latest version. 
# The command has been updated, but if you were specifying it yourself, make sure you're using adb -a -P 5037 server nodaemon. 
# Do NOT use the fork-server argument anymore.
adb -a -P 5037 server nodaemon &
sleep 1

# wait until device is connected and authorized
unauthorized=0
available=0

declare -i index=0
# as default REMOTE_ADB_POLLING_SEC is 5s then we wait for authorizing ~50 sec only
while [[ "$unauthorized" -eq 0 ]] && [[ "$available" -eq 0 ]] && [[ $index -lt 10 ]]
do
    unauthorized=`adb devices | grep -c unauthorized`
    echo "unauthorized: $unauthorized"
    available=`adb devices | grep -c -w device`
    echo "available: $available"
    if [ "$available" -eq 1 ]; then
        # do not wait default 5 sec pause if everything is good
        break
    fi
    sleep ${REMOTE_ADB_POLLING_SEC}
    index+=1
done

info=""
# to support device reboot as device is available by adb but not functionaning correctly.
# this extra dumpsys display call guarantees that android is fully booted
while [[ "$info" == "" ]]
do
    info=`adb shell dumpsys display | grep -A 20 DisplayDeviceInfo`
    echo "info: ${info}"
done
