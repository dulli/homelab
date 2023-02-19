FROM alpine:edge as base
RUN apk add --no-cache python3 py3-pip py3-setuptools py3-wheel
RUN apk add --no-cache curl-dev ffmpeg openssl p7zip sqlite tesseract-ocr

FROM base as builder
RUN apk add --no-cache gcc g++ musl-dev python3-dev libffi-dev openssl-dev jpeg-dev zlib-dev libxml2-dev libxslt-dev cargo
RUN pip3 install --disable-pip-version-check --no-cache-dir --no-compile --upgrade --pre --user pyload-ng[all]

RUN pip3 show pyload-ng > /.version

FROM base
COPY --from=builder /root/.local /usr
COPY --from=builder /.version /.version


ENV CONFIG_PATH /opt/pyload/config
ENV DOWNLOAD_PATH /opt/pyload/download

ADD defaults/pyload.cfg  ${CONFIG_PATH}/settings/pyload.cfg

EXPOSE 8000
EXPOSE 9666

ENTRYPOINT pyload --quit; pyload --storagedir ${DOWNLOAD_PATH} --userdir ${CONFIG_PATH}
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
