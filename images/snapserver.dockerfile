FROM alpine:edge
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories
RUN apk add --no-cache snapcast-server librespot avahi avahi-compat-libdns_sd

ENV CONFIG_PATH=/config/snapserver.conf
COPY defaults/snapserver.conf ${CONFIG_PATH}

COPY defaults/avahi-reflector.conf /etc/avahi/avahi-daemon.conf
RUN rm /etc/avahi/services/*

RUN mkdir -p "/usr/share/snapserver"
RUN wget -qO snapweb.zip "https://github.com/badaix/snapweb/releases/latest/download/snapweb.zip" && unzip -o snapweb.zip -d "/usr/share/snapserver/snapweb/" && rm snapweb.zip

RUN snapserver --version > /.version

EXPOSE 1704
EXPOSE 1705
EXPOSE 1706
EXPOSE 1780

VOLUME /root/.config/snapserver

ENTRYPOINT avahi-daemon --no-chroot --no-rlimits & snapserver -c ${CONFIG_PATH}
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
