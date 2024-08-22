ARG ALPINE_VERSION=3.20
FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache mysql-client curl file jq python3 py3-pip aws-cli

ADD run.sh /run.sh

VOLUME ["/data"]
CMD ["sh", "/run.sh"]
