#!/bin/bash
echo "Iniciando CS 1.6 + Playit..."

cd /hlds/cstrike

# Inicia o servidor CS 1.6 em background
screen -dmS cs16 ./hlds_run -game cstrike -console -port 27015 -maxplayers 16 +map de_dust2

# Espera o HLDS subir
sleep 10

# Faz login no Playit com o token
playit login --token "$PLAYIT_TOKEN"

# Inicia o túnel (use o nome que você criou no painel)
playit tunnel udp --name cs16 --port 27015
