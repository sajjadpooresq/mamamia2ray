#!/bin/bash
# NOTE: no 'set -e' — we log errors and continue so failures are visible in /tmp/xray.log

LOG=/tmp/xray.log

# ─────────────────────────────────────────
#  Generate a random UUID at runtime
# ─────────────────────────────────────────
UUID=$(cat /proc/sys/kernel/random/uuid)

# Restore config from the baked template (idempotent across restarts)
cp /etc/config.json.template /etc/config.json

# Patch the UUID into the fresh config
sed -i "s/PLACEHOLDER_UUID/${UUID}/g" /etc/config.json

# ─────────────────────────────────────────
#  Resolve the public Codespace hostname
#  GitHub sets CODESPACE_NAME automatically
# ─────────────────────────────────────────
if [ -z "$CODESPACE_NAME" ]; then
  echo "⚠️  WARNING: CODESPACE_NAME is not set. Are you running outside a Codespace?"
  PUBLIC_HOST="localhost:8080"
  VLESS_SNI="localhost"
  SECURITY="none"
else
  # Port 8080 forwarded by Codespace → externally reachable as:
  # https://${CODESPACE_NAME}-8080.app.github.dev  (port 443 on the outside)
  PUBLIC_HOST="${CODESPACE_NAME}-8080.app.github.dev"
  VLESS_SNI="${PUBLIC_HOST}"
  SECURITY="tls"
fi

ENCODED_PATH="%2Fvless"

# Build the full VLESS link
VLESS_LINK="vless://${UUID}@${PUBLIC_HOST}:443?encryption=none&security=${SECURITY}&sni=${VLESS_SNI}&allowInsecure=0&type=ws&host=${PUBLIC_HOST}&path=${ENCODED_PATH}#ghtun"

# ─────────────────────────────────────────
#  Print connection details to stdout
#  (and to /tmp/xray.log when run via nohup)
# ─────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          🚀 GHTUN - XRAY SERVICE INITIALIZED 🚀             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Configuration:"
echo "   • UUID:     ${UUID}"
echo "   • Protocol: VLESS + WebSocket + TLS"
echo "   • Port:     8080 (forwarded by GitHub → 443 external)"
echo "   • Path:     /vless"
echo "   • SNI:      ${VLESS_SNI}"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "🔗 COPY THIS VLESS LINK INTO YOUR CLIENT:"
echo ""
echo "${VLESS_LINK}"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "✅ Starting Xray..."
echo ""

# ─────────────────────────────────────────
#  Start xray (foreground — keeps process alive)
# ─────────────────────────────────────────
exec /usr/local/bin/xray -c /etc/config.json
