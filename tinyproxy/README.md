# Tinyproxy:
Tinyproxy is a light-weight HTTP/HTTPS (80/443) proxy daemon for POSIX operating systems.

- podman
  - [Build](#build)
  - [Run](#run)
  - [Run, Custom Config](#run-custom-config)
  - [Stop, Start, Restart](#stop-start-or-restart)
  - [Logs](#logs)
- configuration
  - [filter](#filter)
   - [tinyproxy.conf](#tinyproxy.conf)
      - [Port](#tinyproxy-port)
      - [Filter](#tinyproxy-filter)   
      - [FilterExtended](#FilterExtended)   
      - [FilterDefaultDeny](#FilterDefaultDeny)
      - [FilterURLs](#FilterURLs)
  - [Reference](#reference)

### Build
---
Build and tag an image.  The relative path (here `.`) is to the Dockerfile directory.

```
podman build . -t tinyproxy
```

### Run
---
Run a container.  The `--network=host` is required, otherwise the IP of the incoming request gets changed which renders tinyproxy's IP/subnet filtration useless.

```
podman run --name=tinyproxy --network=host tinyproxy
```

### Run Custom Config
---
Run with custom config mounted in a volume at startup.  This is expected use.

```
podman run --name=tinyproxy -v $(pwd)/conf/:/usr/local/etc/tinyproxy/:z --network=host tinyproxy
```

Note: SELinux distros (e.g. Red Hat, CentOS, Fedora) require `:z` for all volumes.

### Stop, Start or Restart
---
Stop, start or restart a container.  Useful for config changes.

```
podman stop tinyproxy
podman start tinyproxy
podman restart tinyproxy
```

### Logs
---
View the logs for a running container.  Follow/tail with `-f`, or the last N lines with `-tail N`.  Search logs using grep...

```
podman logs tinyproxy
podman logs -f tinyproxy
podman logs tinyproxy --tail N
podman logs tinyproxy | grep pattern
podman logs tinyproxy | grep -i error
```

### Filter
---
The tinyproxy filter file is a whitelist, where the allowed domains (and/or URLs) are stated.  One per line. 

| :warning: **Tinyproxy can not filter HTTPS traffic by URL...** |
|---|
| ...only domain name. |

The format relies on Regular Expresssions (regex) to parse, which is misleading for those unaware because ".gov.bc.ca" # would suggest subdomain support.  For actual subdomain support, the asterisk (*) must be declared after the first period # because the period in regex means "any single character", but requires the asterisk to be read as "any character(s)". For exmaple:

````
.*gov.bc.ca
````

...would match the gov.bc.ca domain, as well as any of its subdomains (as domains resolve right to left). 

### Tinyproxy.conf
---
Tinyproxy reads its configuration file, tinyproxy.conf.  The Tinyproxy configuration file contains key-value pairs, one per line. Lines starting with # and empty lines are comments and are ignored. Keywords are case-insensitive, whereas values are case-sensitive. Values may be enclosed in double-quotes (") if they contain spaces.

| :information_source: **While containerized...** |
|:---|
| ...there's no need to change/address the username and group.  These can be left as "nobody". |

### Tinyproxy Port
---
The default port Tinyproxy listens on is 8888/tcp, but NRM typically uses 23128/tcp.  If using a different port, ensure the port matches the EXPOSE entry in the Dockerfile (which requires a new image).

### Tinyproxy Filter
---
Tinyproxy supports filtering of web sites based on URLs or domains. This option specifies the location of the file containing the filter rules, one rule per line.

| :warning: **Tinyproxy can not filter HTTPS traffic by URL...** |
|---| 
| ...only domain name. |

In the supplied tinyproxy.conf file, the Filter feature is enabled and uses the default path.

```
Filter "/usr/local/etc/tinyproxy/filter"
```

### FilterExtended
---
If this boolean option is set to Yes, then extended POSIX regular expressions are used for matching the filter rules. The default is to use basic POSIX regular expressions.

In the supplied tinyproxy.conf file, the default FilterExtended policy is to allow.  To disable this, comment the following:

```
FilterExtended  On
```

### FilterDefaultDeny
---
The default filtering policy is to allow everything that is not matched by a filtering rule. Setting FilterDefaultDeny to Yes changes the policy do deny everything but the domains or URLs matched by the filtering rules.

In the supplied tinyproxy.conf file, the default policy is to deny.  This requires custom ALLOW statement(s) in the tinyproxy.conf file to grant IP/subnet access to the Tinyproxy instance, and appropriate entries in the filter file for what traffic Tinyproxy will allow through it.  To disable this, comment the following:

```
FilterDefaultDeny Yes
```

### FilterURLs
---
If this boolean option is set to Yes or On, filtering is performed for URLs rather than for domains. The default is to filter based on domains.

In the supplied tinyproxy.conf file, the default FilterURLs policy is to deny.  

| :warning: Tinyproxy can not filter HTTPS traffic by URL... |
|---|
| ...only domain name. |

To enable this, comment the following:

```
#FilterURLs  On
```

### Reference
---
- [tinyproxy.conf(5) - Linux man page](https://linux.die.net/man/5/tinyproxy.conf)