#!/usr/bin/env bash
# VARS_JSON, SECRETS_JSON, VAR_NAMES, SECRET_NAMES
set -euo pipefail

: "${GITHUB_ENV:?}"

export_value() {
  local name="$1" value="$2" delim
  delim="EOF_$(openssl rand -hex 16)"
  {
    printf '%s<<%s\n' "$name" "$delim"
    printf '%s\n' "$value"
    printf '%s\n' "$delim"
  } >>"$GITHUB_ENV"
}

process() {
  local json="$1" names="$2" kind="$3" name value line
  [[ -n "$json" ]] || json='{}'
  for name in $names; do
    if [[ ! "$name" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
      echo "::error::Invalid ${kind} name: ${name}"
      exit 1
    fi
    if ! jq -e --arg n "$name" 'has($n)' <<<"$json" >/dev/null; then
      echo "::error::The ${kind} ${name} is not available to this job."
      exit 1
    fi
    value="$(jq -r --arg n "$name" '.[$n]' <<<"$json")"
    if [[ "$kind" == secret ]]; then
      while IFS= read -r line; do
        if [[ -n "$line" ]]; then
          echo "::add-mask::${line}"
        fi
      done <<<"$value"
    fi
    if [[ "$value" != *$'\n'* ]]; then
      value="$(printf '%s' "$value" | tr -d '[:space:]')"
    fi
    export_value "$name" "$value"
    echo "exported ${kind} ${name}"
  done
}

process "${VARS_JSON:-}" "${VAR_NAMES:-}" variable
process "${SECRETS_JSON:-}" "${SECRET_NAMES:-}" secret
