ARG BASE_IMAGE=debian:stable-slim

FROM ${BASE_IMAGE}

ARG VERSION=5.2.2
ARG ARCH=amd64

RUN apt-get update \
    && apt-get install -y adduser libfontconfig \
    && rm -rf /var/lib/apt/lists/*

ADD https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${VERSION}_${ARCH}.deb /tmp/install.deb

RUN dpkg -i /tmp/install.deb \
    && rm -f /tmp/install.deb

USER grafana

EXPOSE      3000
VOLUME      ["/var/lib/grafana", "/var/log/grafana", "/etc/grafana"]
ENTRYPOINT  [ "/usr/sbin/grafana-server" ]
CMD         [ "--homepath=/usr/share/grafana",                        \
              "--config=/etc/grafana/grafana.ini",                    \
              "$@",                                                   \
              "cfg:default.log.mode=console",                         \
              "cfg:default.paths.data=/var/lib/grafana",              \
              "cfg:default.paths.logs=/var/log/grafana",              \
              "cfg:default.paths.plugins=/var/lib/grafana/plugins" ]
