FROM alpine:3.20

ARG SINGBOX_VER=1.14.4

RUN apk add --no-cache ca-certificates tzdata wget

# 下载并安装 sing-box（musl 版，适配 alpine）
RUN wget -q -O /tmp/sb.tar.gz \
      "https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_VER}/sing-box-${SINGBOX_VER}-linux-amd64-musl.tar.gz" \
 && tar xzf /tmp/sb.tar.gz -C /tmp \
 && find /tmp -name sing-box -type f \
 && cp /tmp/sing-box-${SINGBOX_VER}-linux-amd64-musl/sing-box /usr/local/bin/sing-box \
 && chmod +x /usr/local/bin/sing-box \
 && rm -rf /tmp/sb.tar.gz /tmp/sing-box-* \
 && /usr/local/bin/sing-box version

COPY config.json /etc/sing-box/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
