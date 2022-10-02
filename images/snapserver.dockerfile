FROM alpine:3
RUN apk add --no-cache tar snapcast-server

ENV CONFIG_PATH /config/snapserver.conf
COPY defaults/snapserver.conf $CONFIG_PATH

RUN mkdir -p "/usr/share/snapserver"
RUN wget -qO - "https://github.com/badaix/snapcast/archive/master.tar.gz" | tar -C "/usr/share/snapserver/" -xzv --strip=3 "snapcast-master/server/etc/snapweb"

EXPOSE 1704
EXPOSE 1780

ENTRYPOINT snapserver -c ${CONFIG_PATH}
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
