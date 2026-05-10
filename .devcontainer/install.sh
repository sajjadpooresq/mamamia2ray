#!/bin/sh
set -e

echo "🔍 Fetching latest Xray-core release..."
LATEST=$(wget -qO- https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep '"tag_name"' | cut -d '"' -f 4)

if [ -z "$LATEST" ]; then
  echo "⚠️  Could not fetch latest version, falling back to v24.11.30"
  LATEST="v24.11.30"
fi

echo "📦 Downloading Xray-core ${LATEST}..."
wget -O /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${LATEST}/Xray-linux-64.zip"

echo "📂 Installing..."
cd /tmp && unzip xray.zip xray && chmod +x xray
mv /tmp/xray /usr/local/bin/xray

rm -f /tmp/xray.zip

echo "✅ Xray ${LATEST} installed at /usr/local/bin/xray"
xray version
