FROM golang:1-alpine AS builder
RUN apk add --no-cache jq 
RUN v=$(wget -qO- "https://api.github.com/repos/decke/smtprelay/releases/latest" | jq -r .tag_name); GOBIN=/go/bin go install -ldflags "-X main.appVersion=${v}" "github.com/decke/smtprelay@${v}"

FROM alpine:edge
COPY --from=builder /go/bin/smtprelay /usr/bin/smtprelay

RUN smtprelay -version > /.version

ENTRYPOINT smtprelay -local_key "/tls.key" -local_cert "/tls.crt" -listen starttls://0.0.0.0:2587
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
