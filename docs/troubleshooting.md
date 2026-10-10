# Troubleshooting

## `sha256sum: WARNING: 1 computed checksum did NOT match`

- **Cause:** a tool version was bumped without updating its `*_SHA256`.
- **Fix:** take the checksum from the release checksums file and update the variable
  ([Operations](operations.md#update-pinned-tools)).

## `workflow was not found` when calling a reusable workflow

- **Cause:** wrong path or SHA, or the caller is private and access is not granted.
- **Fix:** check the path `.github/workflows/<name>.yml@<sha>`; see [Repository setup](setup.md#access-for-callers).

## zizmor `self-repository`: use `$/...` instead of `./...`

- **Cause:** zizmor suggests a newer syntax for calling workflows of the same repository that actionlint 1.7.12 rejects.
- **Fix:** the rule is disabled in `.github/zizmor.yml`; revisit when actionlint supports the syntax.

## Scorecard: `workflow verification failed` when publishing

- **Cause:** the Scorecard API verifies the workflow that runs the action and may reject results produced
  inside a reusable workflow.
- **Fix:** set `publish-results: false`, or copy the steps of `scorecard.yml` into the caller workflow.

## SARIF upload fails with `Resource not accessible by integration`

- **Cause:** pull request from a fork, or the caller did not grant `security-events: write`.
- **Fix:** grant the permission to the calling job; pass `upload-sarif: false` for fork pull requests.
