# 0002. Exact versioning and SHA pinning of releases

- Status: proposed
- Date: 2026-10-11

## Context and problem statement

Callers must get reproducible CI and must not pick up changes silently. Floating tags such as `v1`
are convenient but break the platform rule that every dependency is pinned exactly.

## Considered options

1. Floating major tag `v1` moved on every release.
2. Exact tags `vX.Y.Z`, called by tag.
3. Exact tags `vX.Y.Z`, called by full commit SHA with the tag in a comment.

## Decision outcome

Option 3. Tags are immutable; callers write `uses: sogeor/workflows/...@<sha> # vX.Y.Z`, and Renovate
(`helpers:pinGitHubActionDigests`) proposes updates.

### Consequences

- Every update is an explicit, reviewed pull request in the caller.
- Scorecard Pinned-Dependencies is satisfied.
- No floating tags to maintain; the release process is a single tag.
