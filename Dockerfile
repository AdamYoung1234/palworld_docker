FROM ubuntu:22.04

ARG USERNAME=steam
ARG USER_UID=1000
ARG USER_GID=${USER_UID}


##### ========== INSTALL STEAM CMD ==========

# Add non root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

ENV HOME=/steam

RUN mkdir ${HOME}
RUN chown -R ${USERNAME}:${USERNAME} ${HOME}

# Insert Steam prompt answers
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
 && echo steam steam/license note '' | debconf-set-selections

# Update the repository and install SteamCMD
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends ca-certificates locales steamcmd net-tools \
 && rm -rf /var/lib/apt/lists/*

# Add unicode support
RUN locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

# Create symlink for executable
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

USER ${USERNAME}

# Update SteamCMD and verify latest version
RUN steamcmd +quit

# Fix missing directories and libraries
RUN mkdir -p $HOME/.steam \
 && ln -s $HOME/.local/share/Steam/steamcmd/linux32 $HOME/.steam/sdk32 \
 && ln -s $HOME/.local/share/Steam/steamcmd/linux64 $HOME/.steam/sdk64 \
 && ln -s $HOME/.steam/sdk32/steamclient.so $HOME/.steam/sdk32/steamservice.so \
 && ln -s $HOME/.steam/sdk64/steamclient.so $HOME/.steam/sdk64/steamservice.so


##### ========== INSTALL PAL WORLD SERVER ==========
RUN steamcmd +force_install_dir "/steam/palworld" +login anonymous +app_update 2394010 validate +quit

USER root
RUN mkdir /data && chown -R ${USERNAME}:${USERNAME} /data

USER steam
RUN ln -s /data /steam/palworld/Pal/Saved

EXPOSE 8211/udp

ENTRYPOINT ["/steam/palworld/PalServer.sh"]
# CMD ["+help", "+quit"]
