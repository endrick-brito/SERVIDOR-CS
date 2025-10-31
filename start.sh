#!/bin/bash
set -euo pipefail

# ================================
# 🔧 CONFIGURAÇÕES GERAIS
# ================================
SERVER_NAME="${SERVER_NAME:-Servidor do Endrick}"
MAP="${MAP:-de_dust2}"
MAXPLAYERS="${MAXPLAYERS:-12}"
PORT="${PORT:-27015}"
STEAM_ACCOUNT="${STEAM_ACCOUNT:-anonymous}"
PLAYIT_BIN="/opt/cs16-server/playit"

echo "🔧 Iniciando servidor: $SERVER_NAME"
echo "🎮 Mapa: $MAP | MaxPlayers: $MAXPLAYERS | Porta: $PORT"

# ================================
# ⚙️ INSTALAR HLDS (CS 1.6)
# ================================
echo "⬇️ Baixando HLDS via SteamCMD..."
/opt/steamcmd/steamcmd.sh +login $STEAM_ACCOUNT +force_install_dir /opt/cs16-server/hlds +app_set_config 90 mod cstrike +app_update 90 validate +quit

# ================================
# 🔌 COPIAR AMX MOD X (se existir)
# ================================
if [ -d "./amxx_plugins/addons/amxmodx" ]; then
  echo "🔌 Copiando AMX Mod X do repositório..."
  mkdir -p /opt/cs16-server/hlds/cstrike/addons/amxmodx
  cp -r ./amxx_plugins/addons/amxmodx/* /opt/cs16-server/hlds/cstrike/addons/amxmodx/ || true
else
  echo "⚠️ Nenhum AMX Mod X encontrado em ./amxx_plugins/addons/amxmodx."
fi

# ================================
# 🌍 CONFIGURAR PLAYIT.GG
# ================================
echo "⚙️ Preparando Playit.gg..."

# Garantir diretório do servidor
mkdir -p /opt/cs16-server

# Baixar Playit se não existir
if [ ! -f "$PLAYIT_BIN" ]; then
  echo "⬇️ Baixando Playit.gg CLI..."
  curl -L -o "$PLAYIT_BIN" "https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64"
fi

chmod +x "$PLAYIT_BIN"

# Executar Playit em background
echo "🌍 Iniciando túnel Playit.gg..."
"$PLAYIT_BIN" &

# Aguardar inicialização
sleep 6

# Mostrar instrução para vincular conta
if pgrep -f playit >/dev/null; then
  echo "🔗 Se aparecer um link 'https://playit.gg/claim', copie e acesse para vincular sua conta."
  echo "🔎 Depois verifique seu túnel ativo em: https://playit.gg/dashboard"
else
  echo "❌ Falha ao iniciar o agente Playit.gg. Verifique se o binário foi baixado corretamente."
fi

# ================================
# ⚙️ CONFIGURAR SERVER.CFG
# ================================
CFG_PATH="/opt/cs16-server/hlds/cstrike/server.cfg"
mkdir -p "$(dirname "$CFG_PATH")"

cat > "$CFG_PATH" <<EOF
hostname "$SERVER_NAME"
sv_lan 0
sv_region 255
EOF

# ================================
# 🚀 INICIAR HLDS
# ================================
echo "🚀 Iniciando HLDS..."
cd /opt/cs16-server/hlds

if [ -f ./hlds_run ]; then
  ./hlds_run -game cstrike +port "$PORT" +map "$MAP" +maxplayers "$MAXPLAYERS" +sv_name "$SERVER_NAME"
else
  echo "❗ ERRO: hlds_run não encontrado. Verifique a instalação do HLDS."
  exit 1
fi
