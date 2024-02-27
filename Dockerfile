# docker buildx build \
#   --tag 'ghcr.io/scurrnet/mdnsecho' \
#   --label org.opencontainers.image.source=https://github.com/scurrnet/mdnsecho \
#   --label org.opencontainers.image.description="mdns-repeater OCI container for use on MikroTik RouterOS" \
#   . \
# && docker push 'ghcr.io/scurrnet/mdnsecho'

ARG ALPINE_VER=3

FROM alpine:${ALPINE_VER} as builder
RUN set -xe; \
    apk add --update --no-cache \
        alpine-sdk; \
    git clone https://github.com/geekman/mdns-repeater.git /mdnsecho; \
    cd /mdnsecho; \
    make

ARG ALPINE_VER
FROM alpine:${ALPINE_VER}
RUN apk add --update --no-cache \
        openrc \
        vlan; \
    echo 'source /etc/network/interfaces.d/*' >> /etc/network/interfaces; \
    mkdir /etc/network/interfaces.d/; \
    mv /etc/inittab /etc/inittab.000
COPY --from=builder --chown=0:0 --chmod=555 [ "/mdnsecho/mdns-repeater", "/mdns-repeater" ]
COPY [ "${PWD}/_ROOTFS/", "/" ]

ENTRYPOINT ["/sbin/init"]
