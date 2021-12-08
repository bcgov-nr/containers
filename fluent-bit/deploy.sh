#!/bin/bash
#%
#% Fluent Bit deployer
#%
#%   Requires Podman, vault, jq and privileged host access to /proc/stat, and
#%   that your account have access to the Vault secret.
#%   Builds and deploys a local image
#%
#% Usage:
#%   ${THIS_FILE} [Options]
#%
#% Options:
#%   -v, --version <version>    Version number of FluentBit to install, latest.  Default is 1.8.7.
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

FBVERSION="1.8.7"
ENVFILE="$(pwd)/local.env"
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
        --env=?*) # Delete everything up to "=" and assign the remainder:
            ENVFILE=${1#*=}
            ;;
        --env=) # Handle the case of an empty --env=
            die 'ERROR: "--env" requires a non-empty option argument.'
            ;;    
        --rhel=?*) # Delete everything up to "=" and assign the remainder:
            RHEL_VERSION=${1#*=}

            if ((${RHEL_VERSION} <= ${RHEL_VERSION_MIN} || ${RHEL_VERSION} >= ${RHEL_VERSION_MAX}))
            then
                die 'ERROR: "--rhel" only supports versions '"${RHEL_VERSION_MIN}"' to '"${RHEL_VERSION_MAX}"'.'
            fi

            case ${1:-""} in
                7)
                    DOCKERFILE_LOCATION="-f ./Dockerfile_RHEL7"
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
                FBVERSION=$2
                shift
            else
                die 'ERROR: "--version" requires a non-empty option argument.'
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

# Source env file
source "${ENVFILE}"

# Set the Fluent Bit version, build arg and environment variable
export FLUENT_VERSION="${FBVERSION}"

# Verify prerequisites
if ( ! ( which podman && which vault && which jq))
then
    echo -e "\nPlease verify podman, vault and jq are installed\n"
    exit
fi

# Set image and build, if necessary
if [ "${FLUENT_LABEL_ENV}" == "local" ]
then
    podman build -t fluent-bit:"${FLUENT_VERSION}-rhel${RHEL_VERSION}" --build-arg fbVersion="${FLUENT_VERSION}" "${DOCKERFILE_LOCATION}"
    IMAGE="localhost/fluent-bit:${FLUENT_VERSION}-rhel${RHEL_VERSION}"
else
    IMAGE="ghcr.io/bcgov/nr-ansible-fluent-bit:${FLUENT_VERSION}-rhel${RHEL_VERSION}"
fi

# Run in foreground, passing vars
export VAULT_TOKEN="$(vault login -method=oidc -format json 2>/dev/null | jq -r '.auth.client_token')"

# log-opt path - use absolute path ONLY; do not point to Windows drives on WSL 
podman run -i -t --rm --name fluent-bit \
    -e "VAULT_*" -e "AWS_KINESIS_*" -e "FLUENT_*" -e "HOST_*" \
    --pid="host" \
    -v "$(pwd)/conf:/fluent-bit/etc:z" \
    -v "$(pwd)/logs:/fluent-bit/logs:z" \
    -v "/proc/stat:/proc/stat:z" \
    --network=host \
    "${IMAGE}"

if "${ISGENERATE}"
then
    podman generate systemd --new --files --name fluent-bit:"${FLUENT_VERSION}"
if
