FROM alpine:3.15

RUN apk add --no-cache mysql-client curl file jq

ADD run.sh /run.sh

VOLUME ["/data"]
CMD ["sh", "/run.sh"]
