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
#%   -v, --version <version>	Version number of FluentBit to install, latest.  Default is 1.8.7.
#%   -g, --daemon				Generate the systemd unit file for the container. Default is false.
#%   --env=/path/to/file		Specify path to env file. Default is ./local.env.
#%   --RHEL=7					Specify the version of RHEL the container uses.  Default is RHEL8.
#%   -h, -?, --help  			Displays this help dialog.
#%

# Specify halt conditions (errors, unsets, non-zero pipes) and verbosity
set -euo pipefail
[ ! "${VERBOSE:-}" == "true" ] || set -x

FBVERSION="1.8.7"
ENVFILE="$(pwd)/local.env"
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
        --RHEL=?*) # Delete everything up to "=" and assign the remainder:
            RHELversion=${1#*=}            
            ;;
        --RHEL=) # Handle the case of an empty --RHEL=
            die 'ERROR: "--RHEL" requires a non-empty option argument.'           
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
    podman build . -t fluent-bit:"${FLUENT_VERSION}" --build-arg fbVersion="${FLUENT_VERSION}"
    IMAGE="localhost/fluent-bit:${FLUENT_VERSION}"
else
    IMAGE="ghcr.io/bcgov/nr-ansible-fluent-bit:${FLUENT_VERSION}"
fi

# Run in foreground, passing vars
export VAULT_TOKEN="$(vault login -method=oidc -format json 2>/dev/null | jq -r '.auth.client_token')"
podman run -i -t --rm --name fluent-bit -e "VAULT_*" -e "AWS_KINESIS_*" -e "FLUENT_*" -e "HOST_*" -v "$(pwd)/conf:/fluent-bit/etc:z" --pid="host" -v "/proc/stat:/proc/stat:z" --privileged --network=host "${IMAGE}"

if "${ISGENERATE}" then
    podman generate systemd --new --files --name fluent-bit:"${FLUENT_VERSION}"
if
