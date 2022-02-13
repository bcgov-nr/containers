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
#%   -v, --version <version>    Version number of Tomcat to install, latest.  Default is ?.
#%   -v, --version <version>    Version number of OpenJava to install, latest.  Default is ?.
#%   -g, --generate             Generate the systemd unit file for the container. Default is false.
#%   --env=/path/to/file        Specify path to env file. Default is ./local.env.
#%   --rhel=7                   Specify the version of RHEL the container uses.  Default is RHEL8.
#%   -h, -?, --help             Displays this help dialog.
#%

# Specify halt conditions (errors, unsets, non-zero pipes) and verbosity
set -euo pipefail
[ ! "${VERBOSE:-}" == "true" ] || set -x

die() { 
    echo "$*" 1>&2 ; 
    exit 1; 
}

TOMCAT_VERSION="8.0.51"
JRE_VERSION="1.8.0"
LOG4J_VERSION=""
ENVFILE="$(pwd)/local.env"
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
        --env=?*) 
            # Delete everything up to "=" and assign the remainder:
            ENVFILE=${1#*=}
            ;;
        --env=) 
            # Handle the case of an empty --env=
            die 'ERROR: "--env" requires a non-empty option argument.'
            ;;    
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
        -lv|--log4jversion) 
            if [ "$2" ] 
            then
                LOG4J_VERSION=$2
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
    podman build -t tomcat:"${TOMCAT_VERSION}-j${OPENJDK_VERSION}-rhel${RHEL_VERSION}" --build-arg TOMCATVERSION="${TOMCAT_VERSION}" ${DOCKERFILE_LOCATION}
    IMAGE="localhost/tomcat:${TOMCAT_VERSION}-j${OPENJDK_VERSION}-rhel${RHEL_VERSION}"
else
    IMAGE="ghcr.io/bcgov/nr-ansible-tomcat:${TOMCAT_VERSION}-rhel${RHEL_VERSION}"
fi

# log-opt path - use absolute path ONLY; do not point to Windows drives on WSL 
podman run -i -t --rm --name tomcat

if "${ISGENERATE}"
then
    podman generate systemd --new --files --name tomcat:"${TOMCAT_VERSION}"
if
