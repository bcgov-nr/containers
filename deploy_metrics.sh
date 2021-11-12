#!/bin/bash
#%
#% Fluent Bit deployer
#%
#%   Requires Podman, vault, jq and privileged host access to /proc/stat.
#%
#% Usage:
#%   ${THIS_FILE} [TAG]|local
#%
#% Commands:
#%   [TAG] Deploys an image with the specified tag
#%   local Builds and delploys a local image
#%   help  Displays this help dialog
#%
#% Examples:
#%   ${THIS_FILE} latest
#%   ${THIS_FILE} pr-10
#%   ${THIS_FILE} local
#%


# Specify halt conditions (errors, unsets, non-zero pipes) and verbosity
#
set -euo pipefail
[ ! "${VERBOSE:-}" == "true" ] || set -x


# Check parameters - default to showing the help header from this script
#
COMMAND="${1:-help}"
if [ "${COMMAND}" = "help" ]
then
	# Cat this file, grep #% lines and clean up with sed
	THIS_FILE="$(dirname ${0})/$(basename ${0})"
	cat ${THIS_FILE} |
		grep "^#%" |
		sed -e "s|^#%||g" |
		sed -e "s|\${THIS_FILE}|${THIS_FILE}|g"
	exit
fi


# Verify prerequisites
#
if( ! ( which podman && which vault && which jq))
then
	echo -e "\nPlease verify podman, vault and jq are installed\n"
	exit
fi


# Fluent Bit vars
export FLUENT_VERSION=1.7.9
export FLUENT_LABEL_ENV="test"
export FLUENT_INPUT_LOGS_PATH="/sw_ux/httpd0*/logs/hot/*-access*.log*"
export FLUENT_HOME="."


# AWS Kinesis vars
export AWS_KINESIS_STREAM="nress-prod-iit-logs"
export AWS_KINESIS_ROLE_ARN="arn:aws:iam::578527843179:role/PBMMOps-BCGOV_prod_Project_Role_ES_Role"


# Vault vars
#
export VAULT_ADDR="https://vault-iit.apps.silver.devops.gov.bc.ca"
export VAULT_TOKEN="$(vault login -method=oidc -format json 2>/dev/null | jq -r '.auth.client_token')"


# Host Metadata - OS
#
export HOST_OS_FAMILY="$(cat /etc/os-release | grep -e '^ID=' |  cut -d'=' -f2 | xargs)"
export HOST_OS_FULL="$(cat /etc/os-release | grep -e '^PRETTY_NAME=' |  cut -d'=' -f2 | xargs)"
export HOST_OS_KERNEL="$(uname -r)"
export HOST_OS_NAME="$(cat /etc/os-release | grep -e '^NAME=' |  cut -d'=' -f2 | xargs)"
export HOST_OS_TYPE="$(uname)"
export HOST_OS_VERSION="$(cat /etc/os-release | grep -e '^VERSION_ID=' |  cut -d'=' -f2 | xargs)"


# Host Metadata - General
#
export DEFAULT_NET="$(ip route get 8.8.8.8 | cut -d' ' -f5 | grep -v 'cache')"
#
export HOST_ARCH="$(uname -m)"
export HOST_HOSTNAME="$(hostname -s)"
export HOST_ID="$(hostname -f)"
export HOST_IP="$(hostname -I | cut -d' ' -f1)"
export HOST_MAC="$(ip link show ${DEFAULT_NET} | grep -i 'link' | awk '{print $2}' )"
export HOST_NAME="${HOST_HOSTNAME}"
export HOST_DOMAIN="$(echo ${HOST_HOSTNAME#[[:alpha:]]*.})"


# Set image and build, if necessary
#
if [ "${COMMAND}" == "local" ]
then
	podman build $(dirname ${0})/fluent-bit -t fluent-bit
	IMAGE="localhost/fluent-bit"
else
	IMAGE="ghcr.io/bcgov/nr-ansible-fluent-bit:${COMMAND}"
fi


# Run in foreground, passing vars
#
podman run --name fluent-bit --rm -e FLUENT_* -e AWS_* -e VAULT_* -e HOST_* --pid="host" -v "/proc/stat:/proc/stat:ro" --privileged "${IMAGE}"
