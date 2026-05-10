#!/bin/sh
set -e

# Pinned to v24.11.30 — last stable release with full WebSocket support.
# v25+ and v26+ deprecate WebSocket; upgrading requires migrating to XHTTP.
# Change this version intentionally, not by always pulling "latest".
XRAY_VERSION="v24.11.30"

echo "📦 Downloading Xray-core ${XRAY_VERSION}..."
wget -O /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip"

echo "📂 Installing..."
cd /tmp && unzip xray.zip xray && chmod +x xray
mv /tmp/xray /usr/local/bin/xray

rm -f /tmp/xray.zip

echo "✅ Xray ${XRAY_VERSION} installed at /usr/local/bin/xray"
xray version
