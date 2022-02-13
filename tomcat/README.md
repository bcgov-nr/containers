# Tomcat:
Apache Tomcat is an open-source Java webserver.

- About
- podman
  - [Build](#build)
  - [Run](#run)
  - [Stop, Start, Restart](#stop-start-or-restart)
  - [Logs](#logs)

### About
---
This Dockerfile produces an image that, at the time of writting, weighs in at ? MB.  

### Build
---
Build and tag an image.  The relative path (here `.`) is to the Dockerfile directory.

```
podman build . -t tomcat
```

### Run
---
Run a container.  This example specifies the port mapping (the second port value must match the EXPOSE in the Docerkfile); The only other alternative is to use: `--network=host` (which can ).

```
podman run --name=tomcat -p 3000:3000/tcp tomcat
```

### Stop, Start or Restart
---
Stop, start or restart a container.  Useful for config changes.

```
podman stop tomcat
podman start tomcat
podman restart tomcat
```

### Logs
---
View the logs for a running container.  Follow/tail with `-f`, or the last N lines with `-tail N`.  Search logs using grep...

```
podman logs tomcat
podman logs -f tomcat
podman logs tomcat --tail N
podman logs tomcat | grep pattern
podman logs tomcat | grep -i error
```
