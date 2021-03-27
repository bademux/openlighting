FROM scratch as caching-downloader
ADD https://github.com/OpenLightingProject/ola/archive/0.10.8.tar.gz /ola.tar.gz

FROM alpine:3.13.2 as builder
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib64:/usr/local/lib"
COPY --from=caching-downloader / /tmp
WORKDIR /build
RUN tar -zxvf /tmp/ola.tar.gz --strip-components=1
RUN apk add --no-cache --update automake autoconf bison flex ccache g++ libtool libmicrohttpd-dev libusb-compat-dev \
      linux-headers make ncurses ncurses-dev openssl protobuf-dev util-linux-dev libftdi1-dev
#TODO remove --disable-root-check
RUN autoreconf -i && \
    ./configure --disable-doxygen-version --disable-examples --disable-unittests --disable-python-libs --disable-root-check && \
    make install -j$(nproc)

FROM alpine:3.13.2
MAINTAINER bademux
EXPOSE 9090
EXPOSE 9010
RUN apk add --no-cache --update libmicrohttpd libusb-compat protobuf util-linux libusb libftdi1
ENV OLA_OPTS=""
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib64:/usr/local/lib"
COPY --from=builder /usr/local/share /usr/local/share
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
RUN adduser -D olad -G usb
USER olad
ENTRYPOINT olad $OLA_OPTS
