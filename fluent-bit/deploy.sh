#!/bin/bash
#%
#% Fluent Bit deployer
#%
#%   Requires Podman, vault, jq and privileged host access to /proc/stat, and
#%   that your account have access to the Vault secret.
#%   Builds and deploys a local image
#%
#% Usage:
#%   ${THIS_FILE} [FLUENT_VERSION]|1.8.7
#%
#% Commands:
#%   [FLUENT_VERSION] Deploys an image with the specified tag
#%   help  Displays this help dialog
#%
#% Examples:
#%   ${THIS_FILE} 
#%   ${THIS_FILE} 1.7.7
#%

# Specify halt conditions (errors, unsets, non-zero pipes) and verbosity
set -euo pipefail
[ ! "${VERBOSE:-}" == "true" ] || set -x

# Check parameters - default to showing the help header from this script
LATEST=1.8.7
COMMAND="${1:-$LATEST}"
case "$COMMAND" in 
	h* )
		# Cat this file, grep #% lines and clean up with sed
		THIS_FILE="$(dirname ${0})/$(basename ${0})"
		cat ${THIS_FILE} |
			grep "^#%" |
			sed -e "s|^#%||g" |
			sed -e "s|\${THIS_FILE}|${THIS_FILE}|g"
		exit;;
esac

# Source env file
source ./local.env

# Set the Fluent Bit version, build arg and environment variable
export FLUENT_VERSION="${COMMAND}"

# Verify prerequisites
if( ! ( which podman && which vault && which jq))
then
	echo -e "\nPlease verify podman, vault and jq are installed\n"
	exit
fi

# Set image and build, if necessary
if [ "${FLUENT_LABEL_ENV}" == "local" ]
then
	podman build . -t fluent-bit:"${FLUENT_VERSION}" --build-arg fbVersion="${FLUENT_VERSION}"
	IMAGE="localhost/fluent-bit"
else
	IMAGE="ghcr.io/bcgov/nr-ansible-fluent-bit:${FLUENT_LABEL_ENV}"
fi

# Run in foreground, passing vars
export VAULT_TOKEN="$(vault login -method=oidc -format json 2>/dev/null | jq -r '.auth.client_token')"
podman run -i -t --rm --name fluent-bit -e "VAULT_*" -e "AWS_KINESIS_*" -e "FLUENT_*" -e "HOST_*" -v "$(pwd)/conf:/fluent-bit/etc:z" --pid="host" -v "/proc/stat:/proc/stat:z" --privileged --network=host "${IMAGE}"