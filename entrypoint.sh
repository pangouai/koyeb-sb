#!/bin/sh
set -e

PORT="${PORT:-8000}"
UUID="${UUID:-2a7108f4-b462-4d6d-a5f5-d611aef9c35a}"
WS_PATH="${WS_PATH:-/fe82f69e}"

CFG=/etc/sing-box/config.json

# 端口
sed -i "s|\"listen_port\": 8000|\"listen_port\": ${PORT}|" "$CFG"
# UUID
sed -i "s|2a7108f4-b462-4d6d-a5f5-d611aef9c35a|${UUID}|" "$CFG"
# WS 路径
sed -i "s|\"path\": \"/fe82f69e\"|\"path\": \"${WS_PATH}\"|" "$CFG"

echo "=========================================="
echo " sing-box VLESS-WS"
echo "  port : ${PORT}"
echo "  uuid : ${UUID}"
echo "  path : ${WS_PATH}"
echo "=========================================="

exec sing-box run -c "$CFG"
