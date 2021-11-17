# ActiveMQ:
ActiveMQ is an open source message broker, written in Java.

- podman
  - [Build](#build)
  - [Run](#run)
  - [Stop, Start, Restart](#stop-start-or-restart)
  - [Logs](#logs)
- configuration
  - [env](#env)
  - [activemq.xml](#activemq)
  - [jetty-realm](#jetty)

### Build
---
Build and tag an image.  The relative path (here `.`) is to the Dockerfile directory.

```
podman build . -t activemq
```

### Run
---
Run a container.  This example specifies the port mapping (the second port value must match the EXPOSE in the Docerkfile); The only other alternative is to use: `--network=host` (which can ).

```
podman run --name=activemq -p 3000:3000/tcp activemq
```

### Stop, Start or Restart
---
Stop, start or restart a container.  Useful for config changes.

```
podman stop activemq
podman start activemq
podman restart activemq
```

### Logs
---
View the logs for a running container.  Follow/tail with `-f`, or the last N lines with `-tail N`.  Search logs using grep...

```
podman logs activemq
podman logs -f activemq
podman logs activemq --tail N
podman logs activemq | grep pattern
podman logs activemq | grep -i error
```

### env
---
Set the ACTIVEMQ_USER to be the appropriate account:

```
ACTIVEMQ_USER="wwwAbc"
```

### activemq.xml
---
In a load balanced setup, the password entries on the respective hosts should match.

### Jetty-Realm.properties
---
In a load balanced setup, the password entries on the respective hosts should match.