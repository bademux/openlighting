FROM alpine:3.5

ARG OLA_VERSION=0.10.7
ARG LIBLO_VERSION=0.30

MAINTAINER bademux

WORKDIR /tmp

RUN apk add --no-cache libmicrohttpd libusb-compat protobuf util-linux libftdi1

RUN apk add --no-cache --virtual .build-deps \
      automake \
      autoconf \
      bison \
      flex \
      ccache \
      cppunit \
      cppunit-dev \
      g++ \
      git \
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
      libftdi1-dev \
      #remove line on OLA_VERSION=0.10.8 https://github.com/OpenLightingProject/ola/issues/1463
      py-pip && pip install --no-cache-dir protobuf==3.1.0 && \
      #install liblo
      wget --no-check-certificate -nv -O- "https://github.com/radarsat1/liblo/releases/download/$LIBLO_VERSION/liblo-$LIBLO_VERSION.tar.gz" | tar xvz && \
      cd liblo-* &&\
      sed -i 's/-Werror/-Wno-error/' configure.ac &&\
      ./autogen.sh --enable-ipv6 &&\
      make && make install && \
      cd .. && \
      #install OpenLightingProject
      wget --no-check-certificate -nv -O- "https://github.com/OpenLightingProject/ola/releases/download/$OLA_VERSION/ola-$OLA_VERSION.tar.gz" | tar xvz && \
      cd ola* && \
      autoreconf -i && \
      ./configure && \
      make && make install && \
      cd .. && \
      #cleanup
      rm -rf /tmp/* && \
      apk del .build-deps

WORKDIR /

EXPOSE 9090
EXPOSE 9010

RUN adduser -S olad
USER olad

ENTRYPOINT ["olad"]