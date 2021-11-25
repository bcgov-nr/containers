# Fluent Bit:
Fluent Bit is an open source Log Processor and Forwarder which allows you to collect any data like metrics and logs from different sources, enrich them with filters and send them to multiple destinations.  Fluent Bit is a CNCF (Cloud Native Computing Foundation) subproject, under the umbrella of Fluentd.

- podman
  - [Run](#run)
  - [Stop, Start, Restart](#stop-start-or-restart)
  - [Logs](#logs)

### Run
---
The deploy.sh sources the necessary environment variables and such, triggers building the image, before running the image.  The script supports supplying the fluent bit version for the container:

```
./deploy.sh
./deploy.sh latest
./deploy.sh 1.8.6
./deploy.sh 1.7.7
```

The script defaults to local, sourcing local.env 
  - clone/copy the local.env;
  - update for particular environment support; and,
  - update deploy.sh at line 41 to reference the appropriate env file.

#### Notes
---
- Confirm access to the appropriate Vault secret
- The container uses envconsul to capture the Vault token, passing it to the container and ultimately the Fluent Bit agent.  In order to capture the Vault token, you will have to login with IDIR/BCEID.  
- The AWS/kinesis config is commented out, found in outputs.conf.  This is an advanced config, the default container will report host metrics (CPU, memory) to STDOUT.

### Stop, Start or Restart
---
Stop, start or restart a container.  Useful for config changes.

```
podman stop fluent-bit
podman start fluent-bit
podman restart fluent-bit
```

### Logs
---
View the logs for a running container.  Follow/tail with `-f`, or the last N lines with `-tail N`.  Search logs using grep...

```
podman logs fluent-bit
podman logs -f fluent-bit
podman logs fluent-bit --tail N
podman logs fluent-bit | grep pattern
podman logs fluent-bit | grep -i error
```
