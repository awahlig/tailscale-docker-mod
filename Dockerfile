FROM alpine AS build

ARG TARGETPLATFORM

RUN apk add --update curl jq

RUN arch=$(echo ${TARGETPLATFORM} | cut -d/ -f2) \
  && tarball=$(curl 'https://pkgs.tailscale.com/stable/?mode=json' | jq -r .Tarballs.${arch}) \
  && version=$(echo ${tarball} | cut -d_ -f2) \
  && curl "https://pkgs.tailscale.com/stable/${tarball}" -o tailscale.tgz \
  && tar xzf tailscale.tgz \
  && mkdir -p /root-layer/usr/bin /root-layer/usr/sbin \
  && cp -vrf "tailscale_${version}_${arch}"/tailscale /root-layer/usr/bin/tailscale \
  && cp -vrf "tailscale_${version}_${arch}"/tailscaled /root-layer/usr/sbin/tailscaled

COPY root/ /root-layer/

FROM scratch

COPY --from=build /root-layer/ /
