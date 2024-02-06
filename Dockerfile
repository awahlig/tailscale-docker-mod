FROM alpine AS build

ARG TARGETPLATFORM
ARG VERSION

RUN if [ -z "$VERSION" ]; then echo "VERSION is required" && exit 1; fi

RUN apk add --update curl

RUN arch=$(echo ${TARGETPLATFORM} | cut -d/ -f2) \
  && tarball=tailscale_${VERSION}_${arch} \
  && curl -f "https://pkgs.tailscale.com/stable/${tarball}.tgz" -o tailscale.tgz \
  && tar xzf tailscale.tgz \
  && mkdir -p /root-layer/usr/bin /root-layer/usr/sbin \
  && cp -vrf "${tarball}/tailscale" /root-layer/usr/bin/tailscale \
  && cp -vrf "${tarball}/tailscaled" /root-layer/usr/sbin/tailscaled

COPY root/ /root-layer/

FROM scratch

COPY --from=build /root-layer/ /
