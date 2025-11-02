# Usa imagem base leve com 32 bits (necessário pro HLDS)
FROM i386/ubuntu:18.04

# Instala dependências
RUN dpkg --add-architecture i386 && apt update && apt install -y \
    lib32gcc1 wget curl tar screen unzip ca-certificates && \
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

CMD ["/start.sh"]
