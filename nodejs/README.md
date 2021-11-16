# Nodejs:
Node.js is an open-source and cross-platform JavaScript runtime environment.  As an asynchronous event-driven JavaScript runtime, Node.js is designed to build scalable network applications.

- About
- podman
  - [Build](#build)
  - [Run](#run)
  - [Stop, Start, Restart](#stop-start-or-restart)
  - [Logs](#logs)

### About
---
This Dockerfile produces an image that, at the time of writting, weighs in at 85.2 MB.  The nodejs major version is 14.

The Dockerfile starts the RHEL 8.4 UBI, because using RHEL images - this is the only way to gain access to nodejs versions above 10 [supported by RedHat].  Which is fine, because the RHEL UBI-micro version is ultimately used to produce the image.  If the UBI-minimal image was used as a base, `microdnf install nodejs` installed nodejs v10.

The container worked, by copying the entire /usr/lib64/ directory over but the resulting image was around 180 MB.  Copying only the necessary [eight] libraries, trimmed ~100 MB from the resulting image.

### Build
---
Build and tag an image.  The relative path (here `.`) is to the Dockerfile directory.

```
podman build . -t nodejs
```

### Run
---
Run a container.  This example specifies the port mapping (the second port value must match the EXPOSE in the Docerkfile); The only other alternative is to use: `--network=host` (which can ).

```
podman run --name=nodejs -p 3000:3000/tcp nodejs
```

### Stop, Start or Restart
---
Stop, start or restart a container.  Useful for config changes.

```
podman stop nodejs
podman start nodejs
podman restart nodejs
```

### Logs
---
View the logs for a running container.  Follow/tail with `-f`, or the last N lines with `-tail N`.  Search logs using grep...

```
podman logs nodejs
podman logs -f nodejs
podman logs nodejs --tail N
podman logs nodejs | grep pattern
podman logs nodejs | grep -i error
```
