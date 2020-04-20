FROM scratch as caching-downloader

ADD https://github.com/OpenLightingProject/ola/archive/0.10.7.tar.gz /ola.tar.gz

FROM alpine:3.6 as builder 
# alpine:3.6 provides protobuf 3.1 - OLA currently requires protobuf < 3.2, see issue 1192

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib64:/usr/local/lib"

COPY --from=caching-downloader / /tmp
RUN mkdir -p /build/ola  && tar -zxvf /tmp/ola.tar.gz -C /build/ola --strip-components=1

RUN apk add --no-cache \
      automake \
      autoconf \
      bison \
      flex \
      ccache \
      cppunit \
      cppunit-dev \
      g++ \
      libtool \
      libmicrohttpd-dev \
      libusb-compat-dev \
      linux-headers \
      make \
      ncurses \
      ncurses-dev \
      openssl \
      protobuf-dev \
      util-linux-dev \
      libftdi1-dev

RUN cd /build/ola && \
    autoreconf -i && \
    ./configure --disable-all-plugins --disable-doxygen-version --disable-e133--without-dns-sd \
                --disable-unittests --disable-root-check  --disable-examples --disable-python-libs \
                --enable-http --enable-ftdidmx && \
    make && make install

FROM alpine:3.11

MAINTAINER bademux

ENV OLA_OPTS=""
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib64:/usr/local/lib"

WORKDIR /

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/share /usr/local/share

EXPOSE 9090
EXPOSE 9010

RUN apk add --no-cache libmicrohttpd libusb-compat protobuf util-linux libftdi1

RUN adduser -D -H olad
USER olad

ENTRYPOINT olad $OLA_OPTS
