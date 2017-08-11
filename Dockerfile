FROM debian as builder

ARG VERSION=4.4.3
ARG CC_ARCH=""
ARG CC_GOARCH=""

ENV GOPATH=/go
WORKDIR /go/src/github.com/grafana/grafana

RUN apt-get update  \
    && apt-get install --no-install-recommends -y \
            git \
            golang-1.8 \
            wget \
            ca-certificates \
            gcc \
            libc6-dev \
            xz-utils \
            bzip2 \
    && if [ -n "$CC_ARCH" ]; then apt-get install --no-install-recommends -y "gcc-$CC_ARCH-linux-gnu"; fi \
    && ln -s /usr/lib/go-1.8/bin/go /usr/bin/go \
    && git clone -b "v$VERSION" --single-branch https://github.com/grafana/grafana.git . \
    && if [ -n "$CC_ARCH" ]; then \
        export CC=$CC_ARCH-linux-gnu-gcc && \
        export CGO_ENABLED=1 && \
        export GOOS=linux && \
        export GOARCH=$CC_GOARCH ; \
    fi \
    && go build -o dist/grafana-server ./pkg/cmd/grafana-server \
    && wget -O /tmp/node.tar.xz https://nodejs.org/dist/v6.11.2/node-v6.11.2-linux-x64.tar.xz \
    && cd /usr/local \
    && tar --strip-components=1 -xf /tmp/node.tar.xz \
    && rm /tmp/node.tar.xz \
    && cd /go/src/github.com/grafana/grafana \
    && npm install -g yarn \
    && yarn install --pure-lockfile \
    && npm install -g grunt-cli \
    && grunt


FROM alpine:latest

LABEL maintainer "Viktor Adam <rycus86@gmail.com>"

RUN apk --no-cache add --virtual build-dependencies ca-certificates wget  \
        && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub  \
        && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk  \
        && apk del build-dependencies  \
        && apk add glibc-2.25-r0.apk

COPY --from=builder /go/src/github.com/grafana/grafana/dist/grafana-server  /usr/sbin/grafana-server
COPY --from=builder /go/src/github.com/grafana/grafana/conf/defaults.ini    /usr/share/grafana/conf/defaults.ini
COPY --from=builder /go/src/github.com/grafana/grafana/conf/sample.ini      /etc/grafana/grafana.ini
COPY --from=builder /go/src/github.com/grafana/grafana/public_gen           /usr/share/grafana/public
COPY --from=builder /go/src/github.com/grafana/grafana/scripts              /usr/share/grafana/scripts
COPY --from=builder /go/src/github.com/grafana/grafana/vendor               /usr/share/grafana/vendor

EXPOSE      3000
VOLUME      ["/var/lib/grafana", "/var/log/grafana", "/etc/grafana"]
ENTRYPOINT  [ "/usr/sbin/grafana-server" ]
CMD         [ "--homepath=/usr/share/grafana",                          \
              "--config=/etc/grafana/grafana.ini",                      \
              "cfg:default.log.mode='console'",                         \
              "cfg:default.paths.data='/var/lib/grafana'",              \
              "cfg:default.paths.logs='/var/log/grafana'",              \
              "cfg:default.paths.plugins='/var/lib/grafana/plugins'",   \
              "$@" ]
