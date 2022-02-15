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
This container is intended for enabling containerization of legacy tomcat applications; new containerized tomcat would likely already be using [official tomcat containers](https://hub.docker.com/_/tomcat).

This container is meant to produce the tomcat and JDK/JRE combination, that would be consumed as the base image for legacy tomcat containers.  Due to accessibility complications, the JDK/JRE will have to be supplied via volume mount. 

The following images:

```
tomcat:8.0.51-jre8u192
tomcat:8.0.51-jre8u216
```

...would be referenced in a Dockerfile for a given legacy tomcat webapp container as:

```
FROM tomcat:8.0.51-jre8u192

COPY /bin/setenv.sh /usr/local/tomcat/bin
COPY /conf/server.xml /usr/local/tomcat/conf
COPY /webapps/yourContainer /usr/local/tomcat/webapps

EXPOSE 8443

CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]
```

...as there's likely to be more than one legacy tomcat application container that would use tomcat:8.0.51-jre8u192/etc.  In the event of need, assuming the necessary combination of tomcat and JDK/JRE has already been produced, the FROM line just needs to be updated to reflect the desired tomcat container.

Because tomcat is containerized, there's no need to alter the default port tomcat operates on (8443/tcp) - the desired port on the host just needs to be mapped for translation.

### Build
---
Build and tag an image.  The relative path (here `.`) is to the Dockerfile directory.

```
./deploy.sh --version 8.0.51 --port 8123
podman build -t tomcat .
```

### Run
---
Run a container.  This example specifies the port mapping (the second port value must match the EXPOSE in the Docerkfile); The only other alternative is to use: `--network=host` (which can ).

```
./deploy.sh --version 8.0.51 --port 8123
podman run -i -t --rm --name tomcat \
    -v "$(pwd)/jre:/usr/local/tomcat/jre:z" \
    -p <HOST_PORT>:8443/tcp \
    <IMAGE ID>
```

### Stop, Start or Restart
---
Stop, start or restart a container.  Useful for config changes.

```
podman stop tomcat
podman start tomcat
podman restart tomcat
```

If the container is being run as a systemd service, escalate to wwwadm before running:
```
systemctl --user stop container-tomcat
systemctl --user start container-tomcat
systemctl --user restart container-tomcat
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
