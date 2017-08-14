# Grafana on ARM

This project produces [Grafana](https://grafana.com) Docker images for *ARM* hosts.

The available tags are:

- `armhf`: for *32-bits ARM* hosts (built on [Travis](https://travis-ci.org/rycus86/docker-grafana))  
  [![Layers](https://images.microbadger.com/badges/image/rycus86/grafana:armhf.svg)](https://microbadger.com/images/rycus86/grafana:armhf "Get your own image badge on microbadger.com")
- `aarch64`: for *64-bits ARM* hosts (also built on Travis)  
  [![Layers](https://images.microbadger.com/badges/image/rycus86/grafana:aarch64.svg)](https://microbadger.com/images/rycus86/grafana:aarch64 "Get your own image badge on microbadger.com")

The images are all based on *Debian* with the *ARM* images having a
small *QEMU* binary to be able to build them on *x64* hosts.

## Usage

The image uses a similar startup command to the offical
[grafana/grafana](https://hub.docker.com/r/grafana/grafana/) image's.
To be exact:

```dockerfile
ENTRYPOINT  [ "/usr/sbin/grafana-server" ]
CMD         [ "--homepath=/usr/share/grafana",                        \
              "--config=/etc/grafana/grafana.ini",                    \
              "cfg:default.log.mode=console",                         \
              "cfg:default.paths.data=/var/lib/grafana",              \
              "cfg:default.paths.logs=/var/log/grafana",              \
              "cfg:default.paths.plugins=/var/lib/grafana/plugins" ]
```

To run it, use:

```shell
docker run -p 3000:3000 -v /tmp/grafana.ini:/etc/grafana/grafana.ini \
       rycus86/grafana:armhf
```

This will use the *Grafana* config from `/tmp/grafana.ini` to start the
server on port *3000* on *32-bits ARM* hosts.

To run it with __docker-compose__:

```yaml
version: '2'
services:

  grafana:
    image: rycus86/grafana:aarch64
    restart: always
    ports:
     - "3000:3000"
    volumes:
     - /tmp/grafana.ini:/etc/grafana/grafana.ini
```

This will start the *64-bits* version with the same configuration as above.

