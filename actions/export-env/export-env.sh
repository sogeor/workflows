#!/usr/bin/env bash
# VARS_JSON, VAR_NAMES, DOTENV
set -euo pipefail

: "${GITHUB_ENV:?}"

valid_name() {
  [[ "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*$ && "$1" != GITHUB_* && "$1" != RUNNER_* ]]
}

export_value() {
  local name="$1" value="$2" delim
  delim="EOF_$(openssl rand -hex 16)"
  {
    printf '%s<<%s\n' "$name" "$delim"
    printf '%s\n' "$value"
    printf '%s\n' "$delim"
  } >>"$GITHUB_ENV"
}

export_vars() {
  local json="${VARS_JSON:-}" name value
  [[ -n "$json" ]] || json='{}'
  for name in ${VAR_NAMES:-}; do
    if ! valid_name "$name"; then
      echo "::error::Invalid variable name: ${name}"
      exit 1
    fi
    if ! jq -e --arg n "$name" 'has($n)' <<<"$json" >/dev/null; then
      echo "::error::The variable ${name} is not available to this job."
      exit 1
    fi
    value="$(jq -r --arg n "$name" '.[$n]' <<<"$json")"
    if [[ "$value" != *$'\n'* ]]; then
      value="$(printf '%s' "$value" | tr -d '[:space:]')"
    fi
    export_value "$name" "$value"
    echo "exported variable ${name}"
  done
}

export_dotenv() {
  local line name value number=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    number=$((number + 1))
    line="${line%$'\r'}"
    if [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]]; then
      continue
    fi
    if [[ "$line" != *=* ]]; then
      echo "::error::ENV_SECRETS line ${number}: expected NAME=value."
      exit 1
    fi
    name="${line%%=*}"
    name="$(printf '%s' "$name" | tr -d '[:space:]')"
    value="${line#*=}"
    value="$(printf '%s' "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    if ! valid_name "$name"; then
      echo "::error::ENV_SECRETS line ${number}: invalid name."
      exit 1
    fi
    if [[ -z "$value" ]]; then
      echo "::error::ENV_SECRETS line ${number}: empty value for ${name}."
      exit 1
    fi
    echo "::add-mask::${value}"
    export_value "$name" "$value"
    echo "exported secret ${name}"
  done <<<"${DOTENV:-}"
}

export_vars
export_dotenv
