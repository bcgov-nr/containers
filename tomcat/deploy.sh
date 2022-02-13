#!/bin/bash
#%
#% Tomcat deployer
#%
#%   Requires Podman.
#%   Builds and deploys an image, local by default.
#%
#% Usage:
#%   ${THIS_FILE} [Options]
#%
#% Options:
#%   -v, --version <version>        Version number of Tomcat to install, latest.  Default is 8.0.51.
#%   -jv, --jreversion <version>    Version number of Java/JRE to install, latest.  Default is 8u192.
#%   -p, --port <number>            Host port that tomcat (listening on 8443) can be reached at.  Default is 8123.
#%   -g, --generate                 Generate the systemd unit file for the container. Default is false.
#%   --rhel=7                       Specify the version of RHEL the container uses.  Default is RHEL8.
#%   -h, -?, --help                 Displays this help dialog.
#%

# Specify halt conditions (errors, unsets, non-zero pipes) and verbosity
set -euo pipefail
[ ! "${VERBOSE:-}" == "true" ] || set -x

die() { 
    echo "$*" 1>&2 ; 
    exit 1; 
}

CONTAINER_NAME="tomcat"
TOMCAT_VERSION="8.0.51"
JRE_VERSION="8u192"
HOST_PORT="8123"
# ENVFILE="$(pwd)/local.env"
TOMCAT_LABEL_ENV="local"
RHEL_VERSION_MIN=7
RHEL_VERSION_MAX=8
RHEL_VERSION=8
DOCKERFILE_LOCATION="."
ISGENERATE=false

# Check parameters - default to showing the help header from this script
while true 
do
    case ${1:-""} in
        -h|-\?|--help)
            # Cat this file, grep #% lines and clean up with sed
            THIS_FILE="$(dirname ${0})/$(basename ${0})"
            cat ${THIS_FILE} |
                grep "^#%" |
                sed -e "s|^#%||g" |
                sed -e "s|\${THIS_FILE}|${THIS_FILE}|g"
            exit
            ;;
        -g|--generate)
            ISGENERATE=true
            ;;
        # --env=?*) 
        #     # Delete everything up to "=" and assign the remainder:
        #     ENVFILE=${1#*=}
        #     ;;
        # --env=) 
        #     # Handle the case of an empty --env=
        #     die 'ERROR: "--env" requires a non-empty option argument.'
        #     ;;    
        --rhel=?*) 
            # Delete everything up to "=" and assign the remainder:
            RHEL_VERSION=${1#*=}

            if ((${RHEL_VERSION} < ${RHEL_VERSION_MIN} || ${RHEL_VERSION} > ${RHEL_VERSION_MAX}))
            then
                die 'ERROR: "--rhel" only supports versions '"${RHEL_VERSION_MIN}"' to '"${RHEL_VERSION_MAX}"'.'
            fi

            case ${RHEL_VERSION} in
                7)
                    DOCKERFILE_LOCATION="-f Dockerfile_RHEL7"
                    ;;
                8)
                    DOCKERFILE_LOCATION="."
                    ;;
            esac
            ;;
        --rhel=) # Handle the case of an empty --rhel=
            die 'ERROR: "--rhel" requires a non-empty option argument, and only supports versions '"${RHEL_VERSION_MIN}"' to '"${RHEL_VERSION_MAX}"'.'
            ;;                
        -v|--version) 
            if [ "$2" ] 
            then
                TOMCAT_VERSION=$2
                shift
            else
                die 'ERROR: "--version" requires a non-empty option argument.'
            fi
            ;;
        -jv|--jreversion) 
            if [ "$2" ] 
            then
                JRE_VERSION=$2
                shift
            else
                die 'ERROR: "--jreversion" requires a non-empty option argument.'
            fi
            ;;  
        -p|--port) 
            if [ "$2" ] 
            then
                HOST_PORT=$2
                shift
            else
                die 'ERROR: "--jreversion" requires a non-empty option argument.'
            fi
            ;;                                  
        --)  # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            die ''
            ;;
        *) break
    esac
    shift
done

# Verify prerequisites
if ( ! ( which podman))
then
    echo -e "\nPlease verify podman is installed\n"
    exit
fi

# Set image and build, if necessary
if [ "${TOMCAT_LABEL_ENV}" == "local" ]
then
    podman build -t "${CONTAINER_NAME}":"${TOMCAT_VERSION}-jre${JRE_VERSION}" --build-arg TOMCATVERSION="${TOMCAT_VERSION}" --build-arg JREVERSION="${JRE_VERSION}" ${DOCKERFILE_LOCATION}
    IMAGE="localhost/${CONTAINER_NAME}:${TOMCAT_VERSION}-jre${JRE_VERSION}"

    if [ ! -d conf ]; then
      mkdir -p conf;
    fi

    if [ ! -d logs ]; then
      mkdir -p logs;
    fi

    if [ ! -d webapps ]; then
      mkdir -p webapps;
    fi   
else
    IMAGE="ghcr.io/bcgov/nr-ansible-${CONTAINER_NAME}:${TOMCAT_VERSION}-jre${JRE_VERSION}"
fi

# log-opt path - use absolute path ONLY; do not point to Windows drives on WSL 
podman run -i -t --rm --name "${CONTAINER_NAME}" \
    -v "$(pwd)/logs:/usr/local/tomcat/logs:z" \
    -v "$(pwd)/webapps:/usr/local/tomcat/webapps:z" \
    -p ${HOST_PORT}:8443/tcp \
    "${IMAGE}"

# podman run -i -t --rm --name "${CONTAINER_NAME}" \
#     # --pid="host" \
#     # -v "$(pwd)/conf:/usr/local/tomcat/conf:z" \
#     # -v "$(pwd)/logs:/usr/local/tomcat/logs:z" \
#     # -v "$(pwd)/webapps:/usr/local/tomcat/webapps:z" \
#     # -v "/proc/stat:/proc/stat:z" \
#     -p ${HOST_PORT}:8443/tcp \
#     "${IMAGE}"

# if "${ISGENERATE}"
# then
#     podman generate systemd --new --files --name "${CONTAINER_NAME}"

#     ln -s container-"${CONTAINER_NAME}".service /etc/systemd/system

#     if ( (which systemctl))
#     then

#         systemctl --user enable container-"${CONTAINER_NAME}".service

#         # Confirm systemd config
#         systemctl --user is-enabled container-"${CONTAINER_NAME}".service

#         # Start the service
#         systemctl --user start container-"${CONTAINER_NAME}".service

#         # Confirm the status of the service
#         systemctl --user status container-"${CONTAINER_NAME}".service
#     else
#         echo -e "\nPlease verify systemctl is installed\n"
#         exit
#     fi
# if