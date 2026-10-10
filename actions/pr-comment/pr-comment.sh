#!/usr/bin/env bash
# MARKER, BODY_FILE, PR_NUMBER, GH_TOKEN, REPO
set -euo pipefail

: "${MARKER:?}" "${BODY_FILE:?}" "${GH_TOKEN:?}" "${REPO:?}"
if [[ -z "${PR_NUMBER:-}" ]]; then
  echo "No pull request; comment skipped."
  exit 0
fi
if [[ ! "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "::error::Invalid pr-number."
  exit 1
fi
if [[ ! "$MARKER" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "::error::Invalid marker."
  exit 1
fi

tag="<!-- pr-comment:${MARKER} -->"
max=60000
body_file="$(mktemp)"
{
  echo "$tag"
  if (($(wc -c <"$BODY_FILE") > max)); then
    head -c "$max" "$BODY_FILE"
    printf '\n\n_Truncated; see the job log for the full output._\n'
  else
    cat "$BODY_FILE"
  fi
} >"$body_file"

id="$(gh api --paginate "repos/${REPO}/issues/${PR_NUMBER}/comments" \
  --jq ".[] | select(.body | startswith(\"${tag}\")) | .id" | head -n 1)"

if [[ -n "$id" ]]; then
  jq -Rs '{body: .}' <"$body_file" | gh api --method PATCH "repos/${REPO}/issues/comments/${id}" --input - >/dev/null
  echo "updated comment ${id}"
else
  jq -Rs '{body: .}' <"$body_file" | gh api --method POST "repos/${REPO}/issues/${PR_NUMBER}/comments" --input - >/dev/null
  echo "created comment"
fi
