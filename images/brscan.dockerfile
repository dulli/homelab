FROM --platform=linux/amd64 debian:12-slim

RUN apt-get update \
    && apt-get install --no-install-recommends -y sane-utils curl wget udev imagemagick unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "Installing brscan drivers..." \
    && wget -q https://download.brother.com/welcome/dlf006652/brscan-skey-0.3.2-0.amd64.deb \
    && wget -q https://download.brother.com/welcome/dlf104033/brscan5-1.3.0-0.amd64.deb \
    && apt-get --no-install-recommends -y install ./brscan* && rm ./brscan*

RUN wget -q https://github.com/galfar/deskew/releases/download/v1.30/Deskew-1.30.zip \
    && unzip -j "Deskew-1.30.zip" "Deskew/Bin/deskew" -d "/usr/local/bin" && rm Deskew-1.30.zip

RUN echo "Adjusting brscan-skey config ..." \
    && sed -i "s/resolution=100/resolution=300/g" /opt/brother/scanner/brscan-skey/scantofile.config \
    && sed -i "s/.tif//g" /opt/brother/scanner/brscan-skey/script/scantofile.sh \
    && sed -i "s/OPT_FILE=\"--outputfile  \$OUTPUT\"/OPT_FILE=\"--outputfile \$OUTPUT.tif\"/g" /opt/brother/scanner/brscan-skey/script/scantofile.sh \
    && sed -i "s/\$SCANIMAGE \$OPT/\$SCANIMAGE \$OPT \&\& convert \$OUTPUT.tif \$OUTPUT.ppm \&\& deskew -o \$OUTPUT.png \$OUTPUT.ppm \&\& rm \$OUTPUT.tif \$OUTPUT.ppm/g" /opt/brother/scanner/brscan-skey/script/scantofile.sh \
    && sed -i "s/-e \"\$OUTPUT\"/-e \"\$OUTPUT.png\"/g" /opt/brother/scanner/brscan-skey/script/scantofile.sh \
    && sed -i "s/echo \"\$OUTPUT\" is created./echo \"\$OUTPUT.png\" is created./g" /opt/brother/scanner/brscan-skey/script/scantofile.sh 

RUN echo 1.3.0-3 > /.version

ENTRYPOINT ["/bin/sh", "-c" , "service udev restart && brscan-skey && tail -f /dev/null"]
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
