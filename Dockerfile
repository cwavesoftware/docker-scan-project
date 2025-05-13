FROM alpine:latest

RUN apk add --no-cache nmap bash

COPY scan.sh /usr/local/bin/scan.sh

RUN chmod +x /usr/local/bin/scan.sh

WORKDIR /root

CMD ["/usr/local/bin/scan.sh"]