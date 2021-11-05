# TinyProxy Container

Table of Contents:

- [Build](#build)
- [Run](#run)
- [Run, Custom Config](#run-custom-config)
- [Stop, Start, Restart](#stop-start-or-restart)
- [Logs](#logs)

### Build

Build and tag an image.  The relative path (here `.`) is to the Dockerfile directory.

```
podman build . -t tinyproxy
```

### Run

Run a container.  The `--network=host` is required, otherwise the IP of the incoming request gets changed which renders tinyproxy's IP/subnet filtration useless.

```
podman run --name=tinyproxy --network=host tinyproxy
```

### Run Custom Config

Run with custom config mounted in a volume at startup.  This is expected use.

```
podman run --name=tinyproxy -v $(pwd)/conf/:/usr/local/etc/tinyproxy/:z --network=host tinyproxy
```

Note: SELinux distros (e.g. Red Hat, CentOS, Fedora) require `:z` for all volumes.

### Stop, Start or Restart

Stop, start or restart a container.  Useful for config changes.

```
podman stop tinyproxy
podman start tinyproxy
podman restart tinyproxy
```

### Logs

View the logs for a running container.  Follow/tail with `-f`, or the last N lines with `-tail N`.  Search logs using grep...

```
podman logs tinyproxy
podman logs -f tinyproxy
podman logs tinyproxy --tail N
podman logs tinyproxy | grep pattern
podman logs tinyproxy | grep -i error
```
