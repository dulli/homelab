FROM alpine:edge
RUN apk add --no-cache tar snapcast-client

RUN snapclient --version | grep -Eo '[0-9]\.[0-9]+.[0-9]+' > /.version

ENV SNAPSERVER 172.17.0.1

ENTRYPOINT snapclient -h ${SNAPSERVER}
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
