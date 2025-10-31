FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      curl wget tar unzip bzip2 ca-certificates lib32gcc1 lib32stdc++6 procps jq ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Instalar SteamCMD
RUN mkdir -p /opt/steamcmd && \
    cd /opt/steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -O steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

# Instalar ngrok
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O /tmp/ngrok.zip && \
    unzip /tmp/ngrok.zip -d /usr/local/bin && \
    rm /tmp/ngrok.zip

WORKDIR /opt/cs16-server

# Copiar scripts e configs
COPY start.sh /opt/cs16-server/start.sh
COPY server.cfg /opt/cs16-server/server.cfg
COPY amxx_plugins /opt/cs16-server/amxx_plugins

RUN chmod +x /opt/cs16-server/start.sh

# Expor portas (nota: Railway pode não mapear UDP; ngrok TCP será usado)
EXPOSE 27015/udp
EXPOSE 27015/tcp

ENTRYPOINT ["/opt/cs16-server/start.sh"]
