# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Wine
# Minimum Panel Version: 0.6.0
# Based on bregell/docker_wine
# ----------------------------------
FROM danger89/wine-pkgbuilds:latest as buildstage

USER root
RUN         pacman --noconfirm -Syu \
            && chown -R arch /home/arch/ \
            && echo "arch ALL=(ALL:ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)

USER arch
RUN         git clone https://github.com/Tk-Glitch/PKGBUILDS.git /home/arch/PKGBUILDS \
            && cd /home/arch/PKGBUILDS/wine-tkg-git \
            && sed -i 's/_NOINITIALPROMPT="false"/_NOINITIALPROMPT="true"/g' customization.cfg \
            && yes | makepkg -si

FROM        ubuntu:19.10

LABEL       author="lasa01"

ENV         DEBIAN_FRONTEND noninteractive
ENV         WINEARCH win64
ENV         WINEDEBUG fixme-all

# Get wine from buildstage
COPY        --from=buildstage /home/arch/PKGBUILDS/wine-tkg-git/pkg/wine-tkg-*** /
# Ensure wine works
RUN         wine64 --version

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
RUN         wget 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' \
            && mv winetricks /usr/bin/winetricks \
            && chmod +x /usr/bin/winetricks
