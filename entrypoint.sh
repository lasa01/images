#!/bin/bash
cd /home/container
sleep 1
# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Update Source Server
if [ ! -z ${SRCDS_APPID} ]; then
    echo "Updating server"
    if [ ! -z ${SRCDS_BETAID} ]; then
        if [ ! -z ${SRCDS_BETAPASS} ]; then
            ./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container +app_update ${SRCDS_APPID} -beta ${SRCDS_BETAID} -betapassword ${SRCDS_BETAPASS} +quit
        else
            ./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container +app_update ${SRCDS_APPID} -beta ${SRCDS_BETAID} +quit
        fi
    else
        ./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container +app_update ${SRCDS_APPID} +quit
    fi
    # Update mods
    if [ ! -z ${SRCDS_MODS} && ! -z ${SRCDS_MODAPPID} ]; then
        echo "Updating mods"
        UPDATE_MODS="./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container"
        for val in ${SRCDS_MODS}; do
            UPDATE_MODS="$UPDATE_MODS +workshop_download_item ${SRCDS_MODAPPID} $val"
        done
        UPDATE_MODS="$UPDATE_MODS +quit"
        eval $UPDATE_MODS
        
        # Link mods to correct directory for ARK
        for val in ${SRCDS_MODS}; do
            ln -nsf /home/container/steamapps/workshop/content/${SRCDS_MODAPPID}/$val /home/container/ShooterGame/Content/Mods/$val
        done
    fi
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
