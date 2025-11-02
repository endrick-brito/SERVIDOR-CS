# Usa imagem base mais atual (64 bits)
FROM ubuntu:20.04

# Evita interação do apt
ENV DEBIAN_FRONTEND=noninteractive

# Instala dependências 32 bits e utilitários
RUN dpkg --add-architecture i386 && \
    apt update && \
    apt install -y \
        gcc-multilib g++-multilib \
        lib32z1 lib32ncurses6 lib32stdc++6 \
        wget curl tar screen unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Diretório de trabalho
WORKDIR /hlds

# Instala o servidor CS 1.6 via SteamCMD
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    ./steamcmd.sh +login anonymous +force_install_dir /hlds/cstrike \
    +app_update 90 validate +quit

# Copia config e scripts locais
COPY server.cfg /hlds/cstrike/cstrike/server.cfg
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Instala o agente Playit
RUN wget https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 \
    -O /usr/local/bin/playit && chmod +x /usr/local/bin/playit

# Porta padrão CS
EXPOSE 27015/udp

# Comando inicial
CMD ["/start.sh"]
