FROM alpine:3
RUN apk add --no-cache tar snapcast-client

ENV SNAPSERVER 172.17.0.1

ENTRYPOINT snapclient -h ${SNAPSERVER}
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
