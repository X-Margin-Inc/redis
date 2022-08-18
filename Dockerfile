FROM redislabs/redistimeseries:edge as redistimeseries
FROM redislabs/rejson:edge as rejson

FROM alpine:3.9 as builder

MAINTAINER Opstree Solutions

LABEL VERSION=1.0 \
      ARCH=AMD64 \
      DESCRIPTION="A production grade performance tuned redis docker image created by Opstree Solutions"

ARG REDIS_DOWNLOAD_URL="http://download.redis.io/"

ARG REDIS_VERSION="stable"

RUN apk add --no-cache su-exec tzdata make curl build-base linux-headers bash openssl-dev

RUN curl -fL -Lo /tmp/redis-${REDIS_VERSION}.tar.gz ${REDIS_DOWNLOAD_URL}/redis-${REDIS_VERSION}.tar.gz && \
    cd /tmp && \
    tar xvzf redis-${REDIS_VERSION}.tar.gz && \
    cd redis-${REDIS_VERSION} && \
    make && \
    make install BUILD_TLS=yes && \
    mkdir -p /etc/redis && \
    cp -f *.conf /etc/redis

FROM alpine:3.9

MAINTAINER Opstree Solutions

ENV LD_LIBRARY_PATH /usr/lib/redis/modules
ENV REDISGRAPH_DEPS gcompat
ENV REDISTIMESERIES_DEPS libstdc++

WORKDIR /data
RUN set -ex; \
    apk add --no-cache ${REDISTIMESERIES_DEPS}; \
    apk add --no-cache ${REDISGRAPH_DEPS};

LABEL VERSION=1.0 \
      ARCH=AMD64 \
      DESCRIPTION="A production grade performance tuned redis docker image created by Opstree Solutions"

COPY --from=builder /usr/local/bin/redis-server /usr/local/bin/redis-server
COPY --from=builder /usr/local/bin/redis-cli /usr/local/bin/redis-cli
COPY --from=builder /etc/redis /etc/redis
COPY --from=redistimeseries ${LD_LIBRARY_PATH}/*.so ${LD_LIBRARY_PATH}/
COPY --from=rejson ${LD_LIBRARY_PATH}/*.so ${LD_LIBRARY_PATH}/

RUN addgroup -S -g 1001 redis && adduser -S -G redis -u 1001 redis && \
    apk add --no-cache bash

COPY redis.conf /etc/redis/redis.conf

COPY entrypoint.sh /usr/bin/entrypoint.sh

COPY setupMasterSlave.sh /usr/bin/setupMasterSlave.sh

COPY healthcheck.sh /usr/bin/healthcheck.sh

RUN mkdir -p /opt/redis/ && \
    chmod -R g+rwX /etc/redis /opt/redis

VOLUME ["/data"]

WORKDIR /data

EXPOSE 6379

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
