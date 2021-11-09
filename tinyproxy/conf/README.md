# TinyProxy conf
### Table of Contents:
---
- [filter](#filter)
- [tinyproxy.conf](#tinyproxy.conf)
   - [Port](#tinyproxy-port)
   - [Filter](#tinyproxy-filter)   
   - [FilterExtended](#FilterExtended)   
   - [FilterDefaultDeny](#FilterDefaultDeny)
   - [FilterURLs](#FilterURLs)
- [Reference](#reference)

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

| :information_source: **While containerized** |
|---| 
| there's no need to change/address the username and group. |

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