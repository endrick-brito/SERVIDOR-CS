#!/bin/bash
set -euo pipefail

# Configuráveis via variáveis de ambiente
SERVER_NAME="${SERVER_NAME:-Servidor do Endrick}"
MAP="${MAP:-de_dust2}"
MAXPLAYERS="${MAXPLAYERS:-12}"
PORT="${PORT:-27015}"
NGROK_AUTHTOKEN="${NGROK_AUTHTOKEN:-}"
STEAM_ACCOUNT="${STEAM_ACCOUNT:-anonymous}"

echo "🔧 Iniciando: $SERVER_NAME"
echo "🎮 Mapa: $MAP | MaxPlayers: $MAXPLAYERS | Porta: $PORT"

# Validar token ngrok
if [ -z "$NGROK_AUTHTOKEN" ]; then
  echo "❗ ERRO: NGROK_AUTHTOKEN não definido. Defina a variável de ambiente NGROK_AUTHTOKEN."
  exit 1
fi

# 1) Instalar HLDS (Counter-Strike 1.6) via SteamCMD
echo "⬇️ Baixando HLDS via SteamCMD..."
/opt/steamcmd/steamcmd.sh +login $STEAM_ACCOUNT +force_install_dir /opt/cs16-server/hlds +app_set_config 90 mod cstrike +app_update 90 validate +quit

# 2) Copiar AMX Mod X do repositório
if [ -d "./amxx_plugins/addons/amxmodx" ]; then
  echo "🔌 Copiando AMX Mod X do repositório..."
  mkdir -p /opt/cs16-server/hlds/cstrike/addons/amxmodx
  cp -r ./amxx_plugins/addons/amxmodx/* /opt/cs16-server/hlds/cstrike/addons/amxmodx/ || true
else
  echo "⚠️ AMX Mod X não encontrado em ./amxx_plugins/addons/amxmodx. Ignorando."
fi

# 3) Autenticar ngrok e abrir túnel TCP
echo "🔐 Autenticando ngrok..."
/usr/local/bin/ngrok authtoken "$NGROK_AUTHTOKEN"

echo "🌐 Iniciando túnel ngrok (TCP) para a porta $PORT..."
/usr/local/bin/ngrok tcp "$PORT" --log=stdout --log-format=json |
while read -r line; do
    echo "$line"
    # Extrair a URL TCP pública do JSON
    url=$(echo "$line" | jq -r '.url?')
    if [[ $url == tcp* ]]; then
        echo "🔗 IP público do ngrok: $url"
    fi
done &

# 4) Ajustar server.cfg hostname dinamicamente
if [ -f server.cfg ]; then
  echo "hostname \"$SERVER_NAME\"" > /opt/cs16-server/hlds/cstrike/server.cfg || true
fi

# 5) Iniciar HLDS com AMX Mod X (modo foreground)
echo "🚀 Iniciando HLDS..."
cd /opt/cs16-server/hlds
if [ -f ./hlds_run ]; then
  ./hlds_run -game cstrike +port "$PORT" +map "$MAP" +maxplayers "$MAXPLAYERS" +sv_name "$SERVER_NAME"
else
  echo "❗ hlds_run não encontrado. Conteúdos do HLDS podem não ter sido instalados corretamente."
  exit 1
fi
