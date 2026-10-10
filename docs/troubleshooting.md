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

## actionlint: `property "workflow_sha" is not defined`

- **Cause:** actionlint 1.7.12 does not know `job.workflow_ref` and `job.workflow_sha`.
- **Fix:** ignored in `.github/actionlint.yaml`; remove the rule when actionlint supports them.

## `The variable NAME is not available to this job`

- **Cause:** the name is listed in `env-vars` but missing from the Environment.
- **Fix:** add the variable to the Environment named in `environment`.

## `ENV_SECRETS line N: ...`

- **Cause:** a line of `ENV_SECRETS` is not `NAME=value`, the name is invalid, or the value is empty.
- **Fix:** enter the secret again following the rules in [Configuration](configuration.md#infrastructure-workflows-common-rules).

## Provider authentication fails although the secret exists

- **Cause:** the caller did not pass `secrets: inherit`, the run is a pull request from a fork, or the credential
  is a separate secret instead of a line of `ENV_SECRETS`.
- **Fix:** pass `secrets: inherit`; move the credential into `ENV_SECRETS`.

## `Builds run only from master` / `apply runs only from master`

- **Cause:** the workflow was started from another branch.
- **Fix:** run from the default branch; for packer-build experiments set `require-default-branch: false`
  together with an Environment that allows the branch.

## `<host:port> is not reachable through the mesh`

- **Cause:** wrong `WG_*` variables, the runner peer is not registered on the hub, or the hub does not route
  to the target network.
- **Fix:** compare the runner public key with the hub peer list; check `WG_ALLOWED_IPS` and the hub routing.

## OpenTofu: `Error acquiring the state lock` / HTTP 401 from GitLab

- **Cause:** a concurrent apply, or a token without scope `api` or without the Maintainer role.
- **Fix:** wait for the other run; recreate the token with the right scope and role.

## lychee: `503 Service Unavailable` or `429 Too Many Requests` from github.com

- **Cause:** github.com answers anonymous requests to `/blob/` pages with 503 and rate-limits shared runners;
  the link itself is valid.
- **Fix:** `docs.yml` checks `https://github.com/<owner>/<repo>/blob/<ref>/<path>` as
  `https://raw.githubusercontent.com/<owner>/<repo>/<ref>/<path>` (a missing file still fails with 404) and
  retries 5 times with a 10-second pause. Profile and organization pages (`https://github.com/<name>`) answer
  runners with 504 and are not checked. If another github.com page fails, re-run the job.
