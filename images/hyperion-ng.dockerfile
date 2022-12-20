FROM debian:11-slim AS builder
RUN apt-get update
RUN apt-get install -y git cmake build-essential python3-dev qtbase5-dev
RUN apt-get install -y libgl1-mesa-dev libusb-1.0-0-dev libssl-dev libqt5serialport5-dev
RUN git clone --recursive https://github.com/hyperion-project/hyperion.ng.git "/tmp/hyperion"
RUN cd "/tmp/hyperion"; tag=$(git describe --tags `git rev-list --tags --max-count=1`); git checkout $tag
RUN mkdir -p "/tmp/hyperion/build"
WORKDIR /tmp/hyperion/build
RUN cmake -DHYPERION_LIGHT=ON -DENABLE_DEV_SPI=OFF -DENABLE_PROTOBUF_SERVER=ON -DCMAKE_BUILD_TYPE=Release ..
RUN make -j $(nproc)
RUN make install/strip


FROM debian:11-slim
RUN apt-get update && apt-get install -y libgl1 libfreetype6 libusb-1.0-0 libglib2.0-0
COPY --from=builder /usr/local /usr/local

# Ports: Web, JSON-RPC, Protobuf
EXPOSE 8090
EXPOSE 8092
EXPOSE 19444
EXPOSE 19445

ENV CONFIG_PATH /config
ENTRYPOINT /usr/local/bin/hyperiond -v --service -u ${CONFIG_PATH}
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
