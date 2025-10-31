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

if [ -z "$NGROK_AUTHTOKEN" ]; then
  echo "❗ ERRO: NGROK_AUTHTOKEN não definido. Defina a variável de ambiente NGROK_AUTHTOKEN."
  exit 1
fi

# 1) Instalar HLDS (Counter-Strike 1.6) via SteamCMD
echo "⬇️ Baixando HLDS via SteamCMD..."
/opt/steamcmd/steamcmd.sh +login $STEAM_ACCOUNT +force_install_dir /opt/cs16-server/hlds +app_update 90 validate +quit

# 2) Instalar AMX Mod X (versão modular)
echo "⬇️ Instalando AMX Mod X..."
AMXX_URL="https://www.amxmodx.org/release/amxmodx-1.9.0-base-linux.tar.gz"
META_URL="https://www.amxmodx.org/release/amxmodx-1.9.0-builds.tar.gz"
mkdir -p /opt/cs16-server/amx
cd /opt/cs16-server
curl -sSL "$AMXX_URL" -o /tmp/amxx-base.tar.gz
tar -xzf /tmp/amxx-base.tar.gz -C /opt/cs16-server || true
rm /tmp/amxx-base.tar.gz

# Copy basic AMX plugin configuration if present in repo
if [ -d "./amxx_plugins" ]; then
  echo "🔌 Copiando plugins AMX Mod X..."
  mkdir -p /opt/cs16-server/hlds/cstrike/addons/amxmodx
  cp -r ./amxx_plugins/* /opt/cs16-server/hlds/cstrike/addons/amxmodx/ || true
fi

# 3) Autenticar ngrok e abrir túnel TCP
echo "🔐 Autenticando ngrok..."
/usr/local/bin/ngrok authtoken "$NGROK_AUTHTOKEN"

echo "🌐 Iniciando túnel ngrok (TCP) para a porta $PORT..."
/usr/local/bin/ngrok tcp "$PORT" --log=stdout > /opt/cs16-server/ngrok.log 2>&1 &

# Esperar o ngrok criar o túnel
echo "⏳ Aguardando o ngrok iniciar..."
sleep 6

# Mostrar info do túnel (usa o endpoint local do ngrok)
if curl --silent --show-error http://127.0.0.1:4040/api/tunnels > /dev/null 2>&1; then
  echo "🔎 Informações do túnel ngrok:"
  curl --silent --show-error http://127.0.0.1:4040/api/tunnels | jq .
else
  echo "⚠️ Não foi possível acessar a API local do ngrok (127.0.0.1:4040). Verifique logs."
fi

# 4) Ajustar server.cfg hostname dinamicamente se necessário
if [ -f server.cfg ]; then
  echo "hostname \"$SERVER_NAME\"" > /opt/cs16-server/hlds/cstrike/server.cfg || true
fi

# 5) Iniciar HLDS com AMX mod x (modo foreground)
echo "🚀 Iniciando HLDS..."
cd /opt/cs16-server/hlds
# Caso o binário hlds_run não exista, usa hlds_i686 - mas steamcmd deve prover os binários.
if [ -f ./hlds_run ]; then
  ./hlds_run -game cstrike +port "$PORT" +map "$MAP" +maxplayers "$MAXPLAYERS" +sv_name "$SERVER_NAME"
else
  echo "❗ hlds_run não encontrado. Conteúdos do HLDS podem não ter sido instalados corretamente."
  tail -n 100 /opt/cs16-server/ngrok.log || true
  exit 1
fi
