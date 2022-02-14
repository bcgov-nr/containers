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
The Dockerfile is setup to be able to generate a container for whatever desired combination of tomcat and Java (JDK/JRE).  

Due to accessibility complications, the JDK/JRE will have to be supplied via volume mount.  Similarly for the bin, conf, 
logs, and webapps directory contents.  Application specific customizations (eg setenv.sh, server.xml) are to be supplied via the volume mount.  See the infra-containers-config repo for this, while automated with Ansible.

Because tomcat is containerized, there's no need to alter the default port tomcat operates on (8443/tcp) - the desired port on the host just needs to be mapped for translation.  That port can be specified via the deploy.sh, -p/--port flag.

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
./deploy.sh --version 8.0.51 --port 8123 -g
podman run -i -t --rm --name tomcat \
    -v "$(pwd)/bin:/usr/local/tomcat/bin:z" \
    -v "$(pwd)/conf:/usr/local/tomcat/conf:z" \
    -v "$(pwd)/jre:/usr/local/tomcat/jre:z" \
    -v "$(pwd)/logs:/usr/local/tomcat/logs:z" \
    -v "$(pwd)/webapps:/usr/local/tomcat/webapps:z" \
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

Once a container is deployed, the logs should be accessible on the host, via the logs volume mount.
