# About: containers
Fluent Bit, TinyProxy, Ansible, Apache, Tomcat, ActiveMQ, nodejs/npm, and other NR-consumed containers.

# Container Template?
Of the containers currently in this repo, Fluent Bit is the most mature thus the recommended template for containers.  That said, Tinyproxy is in use on nrcpod01.

Here are some of the things that are addressed in the Fluent Bit container:
- **systemd/systemctl service**, in support of auto-start on reboot. [ONETEAM-1893](https://apps.nrs.gov.bc.ca/int/jira/browse/ONETEAM-1893)
- **logging to a mount** rather than SDOUT/journald/k8s-file, to leverage logrotated on the host while supporting applications (tomcat) with that produce more than one log file. [ONETEAM-1809](https://apps.nrs.gov.bc.ca/int/jira/browse/ONETEAM-1809) 
- **fluent-bit/deploy.sh** is a fairly bulletproof template for a local script to build and run a respective container
- **local.env** is provided as an example, for environment specific values and other such files can be supplied/specified via deploy.sh
- **envconsul** is added to the container image, in order to facilitate accessing Vault secrets
- **Dockerfiles** exist for RHEL7 and RHEL8 support, as RHEL UBI differs between these significantly.
- **Fluent Bit** is installed from the tarball, supporting any released version of Fluent Bit at time of building the image.  Prerequisites include flex and bison, notably not available on RHEL for unauthenticated UBI consumers so they too are installed from tarball.  Only the necessary files are copied to the container image that is produced.

# Security
Nothing is currently in place for IIT Security to vet containers.  The state of the discussion is captured on [ONETEAM-1856](https://apps.nrs.gov.bc.ca/int/jira/browse/ONETEAM-1856)

# Remaining Work
- **healthcheck logging/alerting**, which could leverage a webhook (for Teams/Rocketchat/JIRA) interaction [ONETEAM-1635](https://apps.nrs.gov.bc.ca/int/jira/browse/ONETEAM-1635)
- **Repo for Ansible playbook, configs for containers - Tinyproxy** [ONETEAM-1836](https://apps.nrs.gov.bc.ca/int/jira/browse/ONETEAM-1836)
- **Resource consumption comparison** to determine impact of podman for running on legacy hosts and their replacement
