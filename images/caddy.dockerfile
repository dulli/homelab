FROM caddy:2-builder AS builder
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-dynamicdns \
    --with github.com/dulli/caddy-wol \
    --with github.com/hslatman/caddy-crowdsec-bouncer/http@main


FROM caddy:2
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN caddy version > /.version

LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
