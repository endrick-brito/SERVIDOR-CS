#!/bin/bash
set -euo pipefail

# Configurações básicas
SERVER_NAME="${SERVER_NAME:-Servidor do Endrick}"
MAP="${MAP:-de_dust2}"
MAXPLAYERS="${MAXPLAYERS:-12}"
PORT="${PORT:-27015}"
STEAM_ACCOUNT="${STEAM_ACCOUNT:-anonymous}"

echo "🔧 Iniciando: $SERVER_NAME"
echo "🎮 Mapa: $MAP | MaxPlayers: $MAXPLAYERS | Porta: $PORT"

# 1️⃣ Instalar HLDS (Counter-Strike 1.6) via SteamCMD
echo "⬇️ Baixando HLDS via SteamCMD..."
/opt/steamcmd/steamcmd.sh +login $STEAM_ACCOUNT +force_install_dir /opt/cs16-server/hlds +app_set_config 90 mod cstrike +app_update 90 validate +quit

# 2️⃣ Copiar AMX Mod X se existir
if [ -d "./amxx_plugins/addons/amxmodx" ]; then
  echo "🔌 Copiando AMX Mod X do repositório..."
  mkdir -p /opt/cs16-server/hlds/cstrike/addons/amxmodx
  cp -r ./amxx_plugins/addons/amxmodx/* /opt/cs16-server/hlds/cstrike/addons/amxmodx/ || true
else
  echo "⚠️ AMX Mod X não encontrado em ./amxx_plugins/addons/amxmodx. Ignorando."
fi

# 3️⃣ Baixar e configurar Playit.gg
if [ ! -f "/usr/local/bin/playit" ]; then
  echo "⬇️ Baixando Playit.gg..."
  wget -q https://playit.gg/downloads/playit-linux-amd64 -O /usr/local/bin/playit
  chmod +x /usr/local/bin/playit
fi

# 4️⃣ Arquivo de configuração Playit
if [ ! -f "/root/.playit.toml" ]; then
  echo "⚙️ Criando configuração do Playit..."
  echo "👉 Execute o link gerado pelo Playit no log para vincular sua conta."
  /usr/local/bin/playit &
  sleep 10
  pkill playit || true
fi

# 5️⃣ Iniciar o túnel Playit (em background)
echo "🌍 Iniciando túnel Playit.gg..."
/usr/local/bin/playit &

# 6️⃣ Configurar nome do servidor
mkdir -p /opt/cs16-server/hlds/cstrike
echo "hostname \"$SERVER_NAME\"" > /opt/cs16-server/hlds/cstrike/server.cfg

# 7️⃣ Iniciar HLDS
echo "🚀 Iniciando HLDS..."
cd /opt/cs16-server/hlds
if [ -f ./hlds_run ]; then
  ./hlds_run -game cstrike +port "$PORT" +map "$MAP" +maxplayers "$MAXPLAYERS" +sv_lan 0 +sv_name "$SERVER_NAME"
else
  echo "❗ hlds_run não encontrado. HLDS pode não ter sido instalado corretamente."
  exit 1
fi
