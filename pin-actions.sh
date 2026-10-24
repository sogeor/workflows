#!/usr/bin/env bash
# Pin third-party actions to commit SHAs: "uses: owner/repo@v1" -> "uses: owner/repo@<sha> # v1".
# Own reusable workflows (sogeor/*) and local ones (./) keep their tags.
# Usage: pin-actions.sh [files...]   (default: .github/workflows/*.yml)
# Needs: gh (authenticated). Renovate (helpers:pinGitHubActionDigests) keeps the pins updated.
set -euo pipefail
files=("$@"); [ ${#files[@]} -gt 0 ] || files=(.github/workflows/*.yml)
declare -A cache
for f in "${files[@]}"; do
  while IFS= read -r ref; do
    repo="${ref%@*}"; tag="${ref#*@}"
    case "$repo" in sogeor/*|./*) continue ;; esac
    [[ "$tag" =~ ^[0-9a-f]{40}$ ]] && continue
    key="$repo@$tag"
    if [ -z "${cache[$key]:-}" ]; then
      cache[$key]="$(gh api "repos/${repo%%/.github*}/commits/$tag" --jq .sha)"
    fi
    sha="${cache[$key]}"
    sed -i -E "s#uses: ${repo}@${tag}([[:space:]]*\$|[[:space:]]+\#.*\$)#uses: ${repo}@${sha} \# ${tag}#" "$f"
    echo "$f: $repo@$tag -> $sha"
  done < <(grep -oE 'uses: *[^ #]+@[^ #]+' "$f" | sed -E 's/uses: *//' | sort -u)
done
