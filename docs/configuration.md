# Configuration

Every input, secret and output of every workflow is listed here. Call workflows by full commit SHA,
see [Getting started](getting-started.md).

## `docs.yml`

Checks Markdown, links and the MkDocs site of the caller repository.

**Permissions required from the caller:** `contents: read`.

| Input | Type | Default | Required | Description | Example |
|---|---|---|---|---|---|
| `markdown-globs` | string | `*.md`, `docs/**/*.md`, `.github/**/*.md` (one per line) | no | Globs checked by markdownlint; the caller's `.markdownlint.yaml` applies | `README.md` |
| `link-paths` | string | `'*.md' 'docs/**/*.md' '.github/**/*.md'` | no | Space-separated, quoted paths checked by lychee | `'docs/**/*.md'` |
| `link-args` | string | empty | no | Extra lychee arguments; lychee always runs with `--max-retries 5 --retry-wait-time 10` and checks GitHub `/blob/` links through `raw.githubusercontent.com` | `--exclude '^https://example\.com/'` |
| `mkdocs` | boolean | `true` | no | Run `mkdocs build --strict` | `false` |
| `requirements` | string | `.github/requirements-docs.txt` | no | Hash-locked requirements with MkDocs and plugins, installed with `--require-hashes` | `docs/requirements.txt` |

No secrets, no outputs. `GITHUB_TOKEN` is used by lychee to avoid GitHub rate limits.

## `security-lite.yml`

Lightweight security scans of the caller repository; each scanner is a separate job.

**Permissions required from the caller:** `contents: read`; `security-events: write` when `upload-sarif` is `true`.

| Input | Type | Default | Required | Description | Example |
|---|---|---|---|---|---|
| `gitleaks` | boolean | `true` | no | Scan the full Git history for secrets | `false` |
| `trivy` | boolean | `true` | no | Trivy file system scan: vulnerabilities, secrets, misconfigurations | `false` |
| `trivy-severity` | string | `CRITICAL,HIGH` | no | Severities that fail the job; all findings go to SARIF | `CRITICAL` |
| `semgrep` | boolean | `true` | no | Semgrep SAST, metrics off | `false` |
| `semgrep-config` | string | `p/default` | no | Semgrep ruleset from the registry or a path in the repository | `p/ci` |
| `checkov` | boolean | `false` | no | Checkov on infrastructure code | `true` |
| `checkov-frameworks` | string | empty (all) | no | Comma-separated Checkov frameworks | `terraform,github_actions` |
| `upload-sarif` | boolean | `true` | no | Upload results to **Security → Code scanning** | `false` |

No secrets, no outputs. Set `upload-sarif: false` for pull requests from forks: their token cannot write security events.

Pinned tools (environment of the workflow):

| Variable | Description |
|---|---|
| `GITLEAKS_VERSION`, `GITLEAKS_SHA256` | gitleaks release and archive checksum |
| `TRIVY_VERSION`, `TRIVY_SHA256` | Trivy release and archive checksum |
| `SEMGREP_IMAGE` | Semgrep container image, tag and digest |
| `CHECKOV_IMAGE` | Checkov container image, tag and digest |

## `scorecard.yml`

OpenSSF Scorecard analysis of the caller repository.

**Permissions required from the caller:** `contents: read`, `actions: read`, `security-events: write`, `id-token: write`.

| Input | Type | Default | Required | Description | Example |
|---|---|---|---|---|---|
| `publish-results` | boolean | `true` | no | Publish to the Scorecard API for the badge and viewer | `false` |
| `upload-sarif` | boolean | `true` | no | Upload results to code scanning | `false` |

| Secret | Required | Description | Source |
|---|---|---|---|
| `scorecard-token` | no | Enables the Branch-Protection check; `GITHUB_TOKEN` is used when absent | Fine-grained PAT: resource owner — the organization, the repository only, **Administration: Read-only**, 1 year |

No outputs. The SARIF file is also uploaded as artifact `scorecard-sarif` (5 days).

## Infrastructure workflows: common rules

`packer-build`, `tofu-gitlab-state` and `mirror-to-gitlab` run a job in a GitHub Environment of the caller and read
its variables and secrets **by fixed names** ([ADR 0003](adr/0003-environment-scoped-credentials.md)).
The caller passes `secrets: inherit`; the Environment restricts deployment branches to the default branch.

Provider credentials are not fixed:

- non-secret settings are Environment variables listed by name in `env-vars`;
- secrets are lines `NAME=value` in one Environment secret **`ENV_SECRETS`**; every line is exported to the job
  environment and every value is masked.

```text
# ENV_SECRETS for a Proxmox build
PROXMOX_TOKEN=CHANGE_ME
```

Rules for `ENV_SECRETS`: one `NAME=value` per line; names of letters, digits and `_`, not starting with a digit,
`GITHUB_` or `RUNNER_`; the value is everything after the first `=`, surrounding spaces removed; empty lines and
lines starting with `#` are ignored. To rotate one value, enter the whole secret again.
OpenTofu input variables use the `TF_VAR_` prefix: `TF_VAR_proxmox_api_token=CHANGE_ME`.

### Mesh (`mesh: wireguard`)

| Name | Kind | Required | Description | Example |
|---|---|---|---|---|
| `WG_RUNNER_PRIVATE_KEY` | secret | yes | WireGuard private key of the runner peer | output of `wg genkey` |
| `WG_SERVER_PUBLIC_KEY` | variable | yes | Public key of the hub | `CHANGE_ME` |
| `WG_ENDPOINT` | variable | yes | Hub address | `203.0.113.10:51820` |
| `WG_ADDRESS` | variable | yes | Runner address in the WireGuard network | `10.0.0.3/24` |
| `WG_ALLOWED_IPS` | variable | yes | Networks routed through the hub | `10.0.0.0/24, 192.0.2.0/24` |
| `MESH_CHECK_ADDRESS` | variable | no | `host:port` that must accept TCP after connecting | `192.0.2.10:8006` |

## `packer-build.yml`

Builds one Packer image with the caller's build script. Runs only on the default branch unless
`require-default-branch` is `false`.

**Permissions required from the caller:** `contents: read`. **Secrets:** `secrets: inherit`.

| Input | Type | Default | Required | Description | Example |
|---|---|---|---|---|---|
| `environment` | string | — | yes | Environment with build credentials | `images` |
| `image` | string | — | yes | Image name, appended to `build-command` | `ubuntu-2404-base` |
| `build-command` | string | `tools/packer.sh build` | no | Command in the caller repository | `make build` |
| `install-command` | string | empty | no | Command that installs extra tools | `tools/ci-install.sh` |
| `packer-version` | string | `1.16.1` | no | Packer version installed by `hashicorp/setup-packer` | `1.16.1` |
| `build-version` | string | `<run_number>-<run_attempt>` | no | Exported as `PKR_VAR_build_version` | `20261011-1` |
| `packer-vars` | string | empty | no | `NAME=value` per line, exported as `PKR_VAR_NAME` | `base_template=ubuntu-2404-base-v20-1` |
| `env-vars` | string | `PROXMOX_URL PROXMOX_USERNAME` | no | Environment variables exported to the build | `OS_AUTH_URL` |
| `ca-pem-var` | string | empty | no | Variable with a PEM CA added to the system trust store | `PROXMOX_CA_PEM` |
| `mesh` | string | `none` | no | `none` or `wireguard` | `wireguard` |
| `manifest-file` | string | empty | no | Packer manifest read after the build | `manifest/ubuntu-2404-base.json` |
| `manifest-query` | string | `.builds[-1].artifact_id` | no | jq query; one value | `.builds[-1].custom_data.template_name` |
| `artifact-name` | string | `reports-<image>` | no | Uploaded artifact name | `reports-base` |
| `artifact-paths` | string | `reports/`, `manifest/` | no | Uploaded paths, one per line | `out/` |
| `artifact-retention-days` | number | `90` | no | Artifact retention | `30` |
| `timeout-minutes` | number | `90` | no | Job timeout | `120` |
| `debug` | boolean | `false` | no | `PACKER_LOG=1` | `true` |
| `require-default-branch` | boolean | `true` | no | Fail outside the default branch | `false` |

| Output | Description |
|---|---|
| `result` | Result of `manifest-query` (empty without `manifest-file`) |

Also exported to the build: `PKR_VAR_git_sha` (commit SHA), `PACKER_GITHUB_API_TOKEN` (`GITHUB_TOKEN`, plugin downloads).

## `tofu-gitlab-state.yml`

`plan` or `apply` of one OpenTofu root module with state in GitLab-managed Terraform state.

**Permissions required from the caller:** `contents: read`, `pull-requests: write` (plan comments).
**Secrets:** `secrets: inherit`.

| Input | Type | Default | Required | Description | Example |
|---|---|---|---|---|---|
| `command` | string | `plan` | no | `plan`: `-lock=false`, comment on the pull request; `apply`: default branch only | `apply` |
| `working-directory` | string | — | yes | Root module directory | `live/mgmt` |
| `state-name` | string | — | yes | GitLab state name | `mgmt` |
| `environment` | string | — | yes | Environment: read-only credentials for `plan`, read-write for `apply` | `mgmt-plan` |
| `tflint` | boolean | `true` | no | `tflint --init` and `tflint --recursive` | `false` |
| `conftest-policy` | string | empty | no | Rego policies tested against `tofu show -json` | `policies/conftest` |
| `env-vars` | string | empty | no | Environment variables exported to OpenTofu | `TF_VAR_proxmox_url` |
| `mesh` | string | `none` | no | `none` or `wireguard` | `wireguard` |
| `comment` | boolean | `true` | no | Post the plan to the pull request | `false` |

| Output | Description |
|---|---|
| `changes` | `true` when the plan has changes |

Fixed names in the Environment:

| Name | Kind | Required | Description |
|---|---|---|---|
| `GITLAB_TFSTATE_PROJECT_ID` | variable | yes | Numeric ID of the GitLab project that stores state |
| `GITLAB_TFSTATE_USERNAME` | variable | yes | GitLab user that owns the token |
| `GITLAB_TFSTATE_TOKEN` | secret | yes | GitLab token, scope `api`, Maintainer in the project |
| `STATE_PASSPHRASE` | secret | yes | State and plan encryption passphrase, exported as `TF_VAR_state_passphrase` |

Pinned tools: `TOFU_VERSION`/`TOFU_SHA256`, `TFLINT_VERSION`/`TFLINT_SHA256`, `CONFTEST_VERSION`/`CONFTEST_SHA256`.

## `mirror-to-gitlab.yml`

Pushes all branches and tags of the caller repository to a GitLab project; removed branches are pruned.

**Permissions required from the caller:** `contents: read`. **Secrets:** `secrets: inherit`.

| Input | Type | Default | Required | Description | Example |
|---|---|---|---|---|---|
| `environment` | string | — | yes | Environment with the GitLab settings | `mirror` |
| `mesh` | string | `none` | no | `none` or `wireguard` | `wireguard` |
| `ca-pem-var` | string | empty | no | Variable with the PEM CA of GitLab | `GITLAB_CA_PEM` |

| Name | Kind | Required | Description | Example |
|---|---|---|---|---|
| `GITLAB_MIRROR_URL` | variable | yes | GitLab base URL, `https://` | `https://gitlab.example.com` |
| `GITLAB_MIRROR_PROJECT` | variable | yes | Target project path | `group/project` |
| `GITLAB_MIRROR_TOKEN` | secret | yes | Project access token, role Maintainer, scope `write_repository` | `CHANGE_ME` |

## Composite actions

Reference: `uses: sogeor/workflows/actions/<name>@<sha> # vX.Y.Z`.

### `export-env`

| Input | Required | Default | Description |
|---|---|---|---|
| `vars-json` | no | `{}` | `${{ toJSON(vars) }}` |
| `vars` | no | empty | Variable names to export; single-line values trimmed |
| `dotenv` | no | empty | Secret with `NAME=value` lines, usually `${{ secrets.ENV_SECRETS }}` |

A listed variable that is not available, or a malformed `dotenv` line, fails the step.

### `setup-mesh`

| Input | Required | Default | Description |
|---|---|---|---|
| `mode` | yes | — | `wireguard`; `tailscale` fails until implemented |
| `wg-private-key`, `wg-server-public-key`, `wg-endpoint`, `wg-address`, `wg-allowed-ips` | for `wireguard` | empty | See [Mesh](#mesh-mesh-wireguard) |
| `check-address` | no | empty | `host:port` checked over TCP |
| `check-timeout` | no | `60` | Seconds to wait for `check-address` |

### `setup-tofu-http-backend`

| Input | Required | Default | Description |
|---|---|---|---|
| `project-id` | yes | — | GitLab project ID |
| `state-name` | yes | — | State name |
| `username` | yes | — | GitLab user name |
| `token` | yes | — | GitLab token (masked) |
| `gitlab-url` | no | `https://gitlab.com` | GitLab base URL |

Exports `TF_HTTP_ADDRESS`, `TF_HTTP_LOCK_ADDRESS`, `TF_HTTP_UNLOCK_ADDRESS`, `TF_HTTP_LOCK_METHOD=POST`,
`TF_HTTP_UNLOCK_METHOD=DELETE`, `TF_HTTP_RETRY_WAIT_MIN=5`, `TF_HTTP_USERNAME`, `TF_HTTP_PASSWORD`.
The root module declares `backend "http" {}`.

### `pr-comment`

| Input | Required | Default | Description |
|---|---|---|---|
| `marker` | yes | — | Identifies the comment to update |
| `body-file` | yes | — | Markdown file; truncated at 60 000 characters |
| `pr-number` | no | current pull request | Target pull request; skipped when none |
| `token` | no | `GITHUB_TOKEN` | Needs `pull-requests: write` |

## Repository CI

| Name | Kind | Where | Description |
|---|---|---|---|
| `SCORECARD_TOKEN` | secret | repository | Passed to `scorecard.yml` by `repo-scorecard.yml` |
| `ACTIONLINT_VERSION`, `ACTIONLINT_SHA256` | env | `validate.yml` | actionlint release and archive checksum |
| `GITLEAKS_VERSION`, `GITLEAKS_SHA256` | env | `validate.yml` | gitleaks release and archive checksum |
| `.github/zizmor.yml` | file | repository | zizmor configuration; disables `self-repository`, see [Troubleshooting](troubleshooting.md) |
| `.github/actionlint.yaml` | file | repository | Ignores unknown `job.workflow_ref`/`job.workflow_sha`, see [Troubleshooting](troubleshooting.md) |
