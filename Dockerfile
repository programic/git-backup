FROM alpine:3.15

RUN apk add --no-cache jq bash curl git \
    && wget -P / https://raw.githubusercontent.com/programic/bash-common/main/common.sh \
    && mkdir -p /backup/bitbucket \
    && mkdir -p /backup/github

COPY bin /

RUN chmod a+x /*.sh

CMD ["/start-cron.sh"]