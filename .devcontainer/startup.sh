#!/bin/bash
set -e

# ─────────────────────────────────────────
#  Generate a random UUID at runtime
# ─────────────────────────────────────────
UUID=$(cat /proc/sys/kernel/random/uuid)

# Patch the UUID placeholder into the xray config
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
  # Port 8080 forwarded by Codespace → available as:
  # https://${CODESPACE_NAME}-8080.app.github.dev
  PUBLIC_HOST="${CODESPACE_NAME}-8080.app.github.dev"
  VLESS_SNI="${PUBLIC_HOST}"
  SECURITY="tls"
fi

# URL-encode the path
ENCODED_PATH="%2Fvless"

# Build the full VLESS link
VLESS_LINK="vless://${UUID}@${PUBLIC_HOST}:443?encryption=none&security=${SECURITY}&sni=${VLESS_SNI}&allowInsecure=0&type=ws&host=${PUBLIC_HOST}&path=${ENCODED_PATH}#ghtun"

# ─────────────────────────────────────────
#  Print connection details
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
#  Start xray (foreground — keeps container alive)
# ─────────────────────────────────────────
exec /usr/local/bin/xray -c /etc/config.json
