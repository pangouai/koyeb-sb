FROM alpine:latest

ARG SINGBOX_VER=1.14.4
ARG TARGETARCH=amd64

RUN apk add --no-cache curl tar ca-certificates tzdata && \
    curl -L -o /tmp/sb.tar.gz \
      "https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_VER}/sing-box-${SINGBOX_VER}-linux-${TARGETARCH}.tar.gz" && \
    tar xzf /tmp/sb.tar.gz -C /tmp && \
    mv /tmp/sing-box-${SINGBOX_VER}-linux-${TARGETARCH}/sing-box /usr/local/bin/ && \
    chmod +x /usr/local/bin/sing-box && \
    rm -rf /tmp/sb.tar.gz /tmp/sing-box-* && \
    apk del curl tar

COPY config.json /etc/sing-box/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
