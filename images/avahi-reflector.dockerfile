FROM alpine:edge
RUN apk add --no-cache avahi avahi-compat-libdns_sd avahi-tools

RUN avahi-daemon --version > /.version

COPY defaults/avahi-reflector.conf /etc/avahi/avahi-daemon.conf
RUN rm /etc/avahi/services/*

ENTRYPOINT avahi-daemon --no-chroot --no-rlimits
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
