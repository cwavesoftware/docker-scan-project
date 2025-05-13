FROM alpine:latest

RUN apk add --no-cache nmap bash curl jq

COPY scan.sh /usr/local/bin/scan.sh

RUN chmod +x /usr/local/bin/scan.sh

WORKDIR /usr/bin
RUN bash -c 'tools=("slack-notif"); \
    for tool in "${tools[@]}"; do \
        curl -s "https://raw.githubusercontent.com/cwavesoftware/bin/refs/heads/main/$tool" -o "$tool" && \
        chmod +x "$tool"; \
    done'

WORKDIR /root

CMD ["/usr/local/bin/scan.sh"]