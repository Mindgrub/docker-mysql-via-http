FROM alpine:3.18

RUN apk add --no-cache mysql-client curl file jq python3 py3-pip \
    && pip install awscli

ADD run.sh /run.sh

VOLUME ["/data"]
CMD ["sh", "/run.sh"]
