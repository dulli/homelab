FROM debian:12-slim
RUN apt-get update && apt-get install -y sane-utils curl udev imagemagick
RUN curl -O -J https://download.brother.com/welcome/dlf006652/brscan-skey-0.3.2-0.amd64.deb
RUN curl -O -J https://download.brother.com/welcome/dlf104033/brscan5-1.3.0-0.amd64.deb
RUN apt-get install ./brscan* && rm ./brscan*
RUN sed -i "s/resolution=100/resolution=300/g" /opt/brother/scanner/brscan-skey/scantofile.config
RUN sed -i "s/.tif//g" /opt/brother/scanner/brscan-skey/script/scantofile.sh
RUN sed -i "s/OPT_FILE=\"--outputfile  \$OUTPUT\"/OPT_FILE=\"--outputfile \$OUTPUT.tif\"/g" /opt/brother/scanner/brscan-skey/script/scantofile.sh
RUN sed -i "s/\$SCANIMAGE \$OPT/\$SCANIMAGE \$OPT \&\& convert \$OUTPUT.tif \$OUTPUT.png \&\& rm \$OUTPUT.tif/g" /opt/brother/scanner/brscan-skey/script/scantofile.sh
RUN sed -i "s/-e \"\$OUTPUT\"/-e \"\$OUTPUT.png\"/g" /opt/brother/scanner/brscan-skey/script/scantofile.sh
RUN sed -i "s/echo \"\$OUTPUT\" is created./echo \"\$OUTPUT.png\" is created./g" /opt/brother/scanner/brscan-skey/script/scantofile.sh

RUN echo 1.3.0-1 > /.version

ENTRYPOINT ["/bin/sh", "-c" , "service udev restart && brscan-skey && tail -f /dev/null"]
LABEL org.opencontainers.image.source="https://github.com/dulli/homelab"
