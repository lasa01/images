#!/bin/bash
cd /home/container
sleep 1
# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Update Server
if [ ! -z ${STEAM_APPID} ]; then
    ./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container +app_update ${STEAM_APPID} +quit
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
cd /home/container/DedicatedServer64
eval ${MODIFIED_STARTUP}
