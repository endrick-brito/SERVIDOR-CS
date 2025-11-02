#!/bin/bash
echo "Iniciando CS 1.6 + Playit..."

cd /hlds/cstrike

# Inicia o HLDS
screen -dmS cs16 ./hlds_run -game cstrike -console -port 27015 -maxplayers 16 +map de_dust2

# Espera o servidor subir
sleep 10

# Registra o agente com o token
playit agents add --token "$PLAYIT_TOKEN"

# Cria ou ativa o túnel UDP para o CS
playit tunnels add --name SERVIDOR CS --protocol udp --port 27015
