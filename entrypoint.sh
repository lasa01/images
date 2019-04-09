#!/bin/bash
cd /home/container
sleep 1
# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Update Source Server
if [ ! -z ${SRCDS_APPID} ]; then
    echo "Updating server"
    UPDATE_CMD="./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container +app_update ${SRCDS_APPID}"
    if [ ! -z ${SRCDS_BETAID} ]; then
        UPDATE_CMD="$UPDATE_CMD -beta ${SRCDS_BETAID}"
        if [ ! -z ${SRCDS_BETAPASS} ]; then
            UPDATE_CMD="$UPDATE_CMD -betapassword ${SRCDS_BETAPASS}"
        fi
    fi
    # Update mods
    if [ ! -z ${SRCDS_MODS} ] && [ ! -z ${SRCDS_MODAPPID} ]; then
        for val in ${SRCDS_MODS}; do
            UPDATE_CMD="$UPDATE_CMD +workshop_download_item ${SRCDS_MODAPPID} $val"
        done
        # Link mods to correct directory for ARK
        for val in ${SRCDS_MODS}; do
            ln -nsf /home/container/steamapps/workshop/content/${SRCDS_MODAPPID}/$val /home/container/ShooterGame/Content/Mods/$val
        done
    fi
    UPDATE_CMD="$UPDATE_CMD validate +quit"
    eval $UPDATE_CMD
fi
if [ ! -z ${SRCDS_MODS} ] && [ ! -z ${SRCDS_MODAPPID} ]; then
    # Link mods to correct directory for ARK
    for val in ${SRCDS_MODS}; do
        ln -nsf /home/container/steamapps/workshop/content/${SRCDS_MODAPPID}/$val /home/container/ShooterGame/Content/Mods/$val
    done
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
