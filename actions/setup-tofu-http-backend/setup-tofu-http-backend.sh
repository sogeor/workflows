#!/usr/bin/env bash
# PROJECT_ID, STATE_NAME, GITLAB_USERNAME, GITLAB_TOKEN, GITLAB_URL
set -euo pipefail

: "${GITHUB_ENV:?}"
project_id="$(printf '%s' "${PROJECT_ID:?}" | tr -d '[:space:]')"
state="$(printf '%s' "${STATE_NAME:?}" | tr -d '[:space:]')"
user="$(printf '%s' "${GITLAB_USERNAME:?}" | tr -d '[:space:]')"
token="$(printf '%s' "${GITLAB_TOKEN:?}" | tr -d '[:space:]')"
url="$(printf '%s' "${GITLAB_URL:-https://gitlab.com}" | tr -d '[:space:]')"
url="${url%/}"

echo "::add-mask::${token}"
if [[ ! "$project_id" =~ ^[0-9]+$ ]]; then
  echo "::error::project-id must be numeric."
  exit 1
fi
if [[ ! "$state" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "::error::Invalid state-name: ${state}"
  exit 1
fi
if [[ "$url" != https://* ]]; then
  echo "::error::gitlab-url must use https."
  exit 1
fi

address="${url}/api/v4/projects/${project_id}/terraform/state/${state}"
{
  echo "TF_HTTP_ADDRESS=${address}"
  echo "TF_HTTP_LOCK_ADDRESS=${address}/lock"
  echo "TF_HTTP_UNLOCK_ADDRESS=${address}/lock"
  echo "TF_HTTP_LOCK_METHOD=POST"
  echo "TF_HTTP_UNLOCK_METHOD=DELETE"
  echo "TF_HTTP_RETRY_WAIT_MIN=5"
  echo "TF_HTTP_USERNAME=${user}"
  echo "TF_HTTP_PASSWORD=${token}"
} >>"$GITHUB_ENV"
echo "http backend: ${address}"
