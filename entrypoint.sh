#!/bin/sh
set -e

# ---------- sing-box 配置 ----------
sed -e "s|__UUID__|${NODE_UUID}|g" \
    -e "s|__PATH__|${NODE_PATH}|g" \
    /opt/singbox/config.tpl.json > /opt/singbox/config.json

# ---------- OpenList 配置 ----------
# 数据库全部走环境变量，容器重启不丢数据
cat > /opt/openlist/config.json <<EOF
{
  "force": false,
  "jwt_secret": "${OL_JWT_SECRET:-random_generated}",
  "database": {
    "type": "postgres",
    "host": "${DB_HOST}",
    "port": ${DB_PORT:-5432},
    "user": "${DB_USER}",
    "password": "${DB_PASS}",
    "name": "${DB_NAME:-postgres}",
    "db_file": "",
    "table_prefix": "${DB_PREFIX:-x_}",
    "ssl_mode": "${DB_SSLMODE:-require}",
    "dsn": ""
  },
  "scheme": {
    "address": "127.0.0.1",
    "http_port": ${OL_PORT:-5244}
  },
  "temp_dir": "/tmp/temp",
  "bleve_dir": "/tmp/bleve",
  "log": { "enable": true, "level": "info" }
}
EOF

echo "=========================================="
echo " node  : ${NODE_PATH}"
echo " ol    : 127.0.0.1:${OL_PORT:-5244}"
echo " sb    : 127.0.0.1:${SB_PORT:-10000}"
echo " caddy : :${PORT:-8000}"
echo " db    : ${DB_HOST}/${DB_NAME:-postgres}"
echo "=========================================="

# ---------- 启动 ----------
sing-box run -c /opt/singbox/config.json &
SB=$!

/opt/openlist/openlist server --config /opt/openlist/config.json &
OL=$!

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
CD=$!

echo "pids: sing-box=$SB openlist=$OL caddy=$CD"

# 任一退出则整体退出，交给 Koyeb 重启
wait -n $SB $OL $CD || true
echo "one process exited, shutting down"
kill $SB $OL $CD 2>/dev/null || true
exit 1
