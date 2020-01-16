# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Wine
# Minimum Panel Version: 0.6.0
# Based on bregell/docker_wine
# ----------------------------------
FROM        ubuntu:19.10

LABEL       author="lasa01"

ENV         DEBIAN_FRONTEND noninteractive
ENV         WINEARCH win64
ENV         WINEDEBUG fixme-all

# Install Dependencies
RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get upgrade -y 
RUN         apt-get install -y --no-install-recommends --no-install-suggests \
                        lib32stdc++6 \
                        lib32gcc1 \
                        wget \
                        ca-certificates \
                        apt-utils \
                        sed \
                        software-properties-common \
                        apt-transport-https \
                        xvfb \
                        iproute2 \
                        net-tools \
                        gpg-agent
RUN         wget -nc https://dl.winehq.org/wine-builds/winehq.key \
            && apt-key add winehq.key \
            && apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ eoan main'
RUN         apt-get update \
            && apt-get install -y --no-install-recommends --no-install-suggests --allow-unauthenticated \
                winehq-stable \
                cabextract
RUN         wget 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' \
            && mv winetricks /usr/bin/winetricks \
            && chmod +x /usr/bin/winetricks
