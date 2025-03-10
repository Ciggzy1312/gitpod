#!/usr/bin/env bash

set -euo pipefail

export HOME=/home/gitpod
export PREVIEW_ENV_DEV_SA_KEY_PATH="$HOME/.config/gcloud/preview-environment-dev-sa.json"

# Don't prompt user before terraform apply
export TF_INPUT=0
export TF_IN_AUTOMATION=true

echo "${INPUT_SA_KEY}" > "${PREVIEW_ENV_DEV_SA_KEY_PATH}"
gcloud auth activate-service-account --key-file "${PREVIEW_ENV_DEV_SA_KEY_PATH}"

# Hack alert: We're building previewctl here until we decide how to properly distribute internal tools
# Also, LEEWAY_WORKSPACE_ROOT is set to /workspace/gitpod in our dev image, but that's not the path GH actions use
# shellcheck disable=SC2155
export LEEWAY_WORKSPACE_ROOT="$(pwd)"
leeway run dev/preview/previewctl:install --dont-test

previewctl get-credentials --gcp-service-account "${PREVIEW_ENV_DEV_SA_KEY_PATH}"

leeway run dev/preview:create-preview
