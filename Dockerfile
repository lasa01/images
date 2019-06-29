# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Wine
# Minimum Panel Version: 0.6.0
# Based on bregell/docker_wine
# ----------------------------------
FROM        ubuntu:18.04

LABEL       author="lasa01"

ENV         DEBIAN_FRONTEND noninteractive
ENV         WINEARCH win64
# Install Dependencies
RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y --no-install-recommends --no-install-suggests \
                        lib32stdc++6 \
                        lib32gcc1 \
                        wget \
                        ca-certificates \
                        apt-utils \
                        sed \
                        software-properties-common \
			apt-transport-https \
			xvfb \
                        gpg-agent \
            && wget -nc https://dl.winehq.org/wine-builds/Release.key \
            && apt-key add Release.key \
            && apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ \
            && apt-get update \
            && apt-get install -y --no-install-recommends --no-install-suggests --allow-unauthenticated \
                winehq-devel \
                cabextract \
            && wget 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' \
            && mv winetricks /usr/bin/winetricks \
            && chmod +x /usr/bin/winetricks \
            && WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init \
            && xvfb-run winetricks -q vcrun2013 vcrun2017 \
            && wineboot --init \
            && winetricks -q dotnet472 corefonts \
            && wineboot --init \
            && winetricks -q dxvk \
            && useradd -m -d /home/container container

USER        container
ENV         HOME /home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
