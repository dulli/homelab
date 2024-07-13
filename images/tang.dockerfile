FROM alpine:edge AS builder
RUN apk add --no-cache --update \
    bash \
    g++ gawk git gmp gzip \
    http-parser-dev \
    isl-dev \
    jansson-dev \
    meson mpc1-dev mpfr-dev musl-dev \
    ninja \
    openssl-dev \
    tar \
    zlib-dev \
    curl jq

RUN tag=$(curl https://api.github.com/repos/latchset/jose/releases/latest | jq -r ".tag_name") \
    && git clone --depth 1 --branch $tag https://github.com/latchset/jose \
    && mkdir jose/build && cd jose/build \
    && meson setup .. --prefix=/usr/local \
    && ninja install

RUN tag=$(curl https://api.github.com/repos/latchset/tang/releases/latest | jq -r ".tag_name") \
    && git clone --depth 1 --branch $tag https://github.com/latchset/tang \
    && mkdir tang/build && cd tang/build \
    && meson setup .. --prefix=/usr/local \
    && ninja install

FROM alpine:edge
COPY --from=builder /usr/local/bin/jose /usr/local/bin/jose
COPY --from=builder /usr/local/lib/libjose.so.0 /usr/local/lib/libjose.so.0
COPY --from=builder /usr/local/lib/libjose.so.0.0.0 /usr/local/lib/libjose.so.0.0.0
COPY --from=builder /usr/local/libexec/tangd /usr/local/bin/tangd
COPY --from=builder /usr/local/libexec/tangd-keygen /usr/local/bin/tangd-keygen
RUN apk add --no-cache --update \
    http-parser \
    jansson \
    openssl \
    zlib \
    && tangd --version > /.version

ENV PORT 7500

EXPOSE $PORT
VOLUME ["/db"]

ENTRYPOINT tangd -l --port $PORT "/db"
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
