FROM alpine:3.20

ARG SINGBOX_VER=1.14.4
ARG OPENLIST_VER=4.2.9

RUN apk add --no-cache ca-certificates tzdata wget tar caddy libstdc++

# ---------- sing-box ----------
RUN wget -q -O /tmp/sb.tar.gz \
      "https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_VER}/sing-box-${SINGBOX_VER}-linux-amd64-musl.tar.gz" \
 && tar xzf /tmp/sb.tar.gz -C /tmp \
 && cp /tmp/sing-box-${SINGBOX_VER}-linux-amd64-musl/sing-box /usr/local/bin/sing-box \
 && chmod +x /usr/local/bin/sing-box \
 && rm -rf /tmp/sb.tar.gz /tmp/sing-box-* \
 && sing-box version

# ---------- OpenList ----------
RUN wget -q -O /tmp/ol.tar.gz \
      "https://github.com/OpenListTeam/OpenList/releases/download/v${OPENLIST_VER}/openlist-linux-musl-amd64-lite.tar.gz" \
 && mkdir -p /opt/openlist \
 && tar xzf /tmp/ol.tar.gz -C /opt/openlist \
 && chmod +x /opt/openlist/openlist \
 && rm -f /tmp/ol.tar.gz \
 && /opt/openlist/openlist version

COPY singbox.tpl.json /opt/singbox/config.tpl.json
COPY Caddyfile        /etc/caddy/Caddyfile
COPY entrypoint.sh    /entrypoint.sh
RUN chmod +x /entrypoint.sh \
 && mkdir -p /opt/openlist/data /tmp/temp /tmp/bleve /data

ENV TZ=Asia/Shanghai \
    NODE_UUID=2a7108f4-b462-4d6d-a5f5-d611aef9c35a \
    NODE_PATH=/fe82f69e \
    OL_PORT=5244 \
    SB_PORT=10000 \
    PORT=8000 \
    DB_PORT=5432 \
    DB_NAME=postgres \
    DB_PREFIX=x_ \
    DB_SSLMODE=require

EXPOSE 8000

CMD ["/entrypoint.sh"]
