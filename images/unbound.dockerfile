FROM alpine:edge
RUN apk add --no-cache unbound ca-certificates
RUN update-ca-certificates

RUN unbound -V > /.version

COPY defaults/unbound.conf /etc/unbound/unbound.conf

RUN unbound-anchor
RUN chown -R unbound:unbound /usr/share/dnssec-root/

ENTRYPOINT unbound -d
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
