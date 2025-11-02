#!/bin/bash
echo "Iniciando servidor CS 1.6 + Playit..."

# Inicia o servidor em background
cd /hlds/cstrike
screen -dmS cs16 ./hlds_run -game cstrike -console -port 27015 -maxplayers 16 +map de_dust2

# Espera um pouco pro HLDS subir
sleep 10

# Inicia o túnel Playit (substitua pelo seu token)
playit --token $PLAYIT_TOKEN
