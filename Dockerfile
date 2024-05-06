ARG FIVEM_NUM=8085
ARG FIVEM_VER=8085-4695ec7001ea2009675e5a7582928d6bbc6e9d77
ARG DATA_VER=0e7ba538339f7c1c26d0e689aa750a336576cf02

FROM spritsail/alpine:3.19 as builder

ARG FIVEM_VER
ARG DATA_VER

WORKDIR /output

RUN wget -O- https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FIVEM_VER}/fx.tar.xz \
        | tar xJ --strip-components=1 \
            --exclude alpine/dev --exclude alpine/proc \
            --exclude alpine/run --exclude alpine/sys \
 && mkdir -p /output/opt/cfx-server-data /output/usr/local/share \
 && wget -O- http://github.com/citizenfx/cfx-server-data/archive/${DATA_VER}.tar.gz \
        | tar xz --strip-components=1 -C opt/cfx-server-data \
    \
 && apk -p $PWD add tini

ADD server.cfg opt/cfx-server-data
ADD entrypoint usr/bin/entrypoint

WORKDIR "/output/opt/cfx-server-data/resources/[custom]"

# Bob74 Map Fixes
RUN wget https://github.com/Bob74/bob74_ipl/archive/refs/tags/2.2.1.zip -O bob74.zip
RUN unzip bob74.zip -d . && rm bob74.zip

# Custom Resource
RUN wget https://github.com/fivem-dx-plus/dxp-ts-resources/releases/download/release/release.zip
RUN unzip release.zip -d dxp-ts-resources && rm release.zip

RUN chmod +x /output/usr/bin/entrypoint

#================

FROM scratch

ARG FIVEM_VER
ARG FIVEM_NUM
ARG DATA_VER

LABEL maintainer="Spritsail <fivem@spritsail.io>" \
      org.label-schema.vendor="Spritsail" \
      org.label-schema.name="FiveM" \
      org.label-schema.url="https://fivem.net" \
      org.label-schema.description="FiveM is a modification for Grand Theft Auto V enabling you to play multiplayer on customized dedicated servers." \
      org.label-schema.version=${FIVEM_NUM} \
      io.spritsail.version.fivem=${FIVEM_VER} \
      io.spritsail.version.fivem_data=${DATA_VER}

COPY --from=builder /output/ /

WORKDIR /config
EXPOSE 30120

# Default to an empty CMD, so we can use it to add seperate args to the binary
CMD [""]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
