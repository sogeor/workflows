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
| `link-args` | string | empty | no | Extra lychee arguments | `--exclude '^https://example\.com/'` |
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

## Repository CI

| Name | Kind | Where | Description |
|---|---|---|---|
| `SCORECARD_TOKEN` | secret | repository | Passed to `scorecard.yml` by `repo-scorecard.yml` |
| `ACTIONLINT_VERSION`, `ACTIONLINT_SHA256` | env | `validate.yml` | actionlint release and archive checksum |
| `GITLEAKS_VERSION`, `GITLEAKS_SHA256` | env | `validate.yml` | gitleaks release and archive checksum |
| `.github/zizmor.yml` | file | repository | zizmor configuration; disables `self-repository`, see [Troubleshooting](troubleshooting.md) |
