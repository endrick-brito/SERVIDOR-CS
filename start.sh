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
PLAYIT_BIN="/usr/local/bin/playit"

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
# 🌍 INICIAR PLAYIT.GG
# ================================
echo "⚙️ Preparando Playit.gg..."

# Garantir que o executável do Playit exista
if [ ! -f "$PLAYIT_BIN" ]; then
  echo "⬇️ Baixando Playit.gg CLI..."
  curl -sSL "https://playit.gg/downloads/playit-linux-amd64" -o "$PLAYIT_BIN"
fi

chmod +x "$PLAYIT_BIN"

echo "🌍 Iniciando túnel Playit.gg..."
$PLAYIT_BIN &

# Aguardar o Playit inicializar
sleep 6

# Mostrar instrução de vinculação, caso ainda não esteja vinculado
if grep -q "Visit https://playit.gg/link" /proc/$(pgrep -f playit)/fd/1 2>/dev/null; then
  echo "🔗 Acesse o link acima para vincular sua conta Playit.gg."
else
  echo "✅ Playit.gg iniciado. Verifique seu painel em https://playit.gg/dashboard"
fi

# ================================
# ⚙️ CONFIGURAR SERVER.CFG
# ================================
CFG_PATH="/opt/cs16-server/hlds/cstrike/server.cfg"
mkdir -p "$(dirname "$CFG_PATH")"

echo "hostname \"$SERVER_NAME\"" > "$CFG_PATH"
echo "sv_lan 0" >> "$CFG_PATH"
echo "sv_region 255" >> "$CFG_PATH"

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
