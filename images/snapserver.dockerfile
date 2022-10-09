FROM alpine:edge
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories
RUN apk add --no-cache tar snapcast-server librespot dbus avahi avahi-compat-libdns_sd

ENV CONFIG_PATH /config/snapserver.conf
COPY defaults/snapserver.conf $CONFIG_PATH

RUN mkdir -p "/usr/share/snapserver"
RUN wget -qO - "https://github.com/badaix/snapcast/archive/master.tar.gz" | tar -C "/usr/share/snapserver/" -xzv --strip=3 "snapcast-master/server/etc/snapweb"

EXPOSE 1704
EXPOSE 1705
EXPOSE 1780

ENTRYPOINT dbus-daemon --system; avahi-daemon --no-chroot & snapserver -c ${CONFIG_PATH}
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
