# Workflows and actions

## Reusable workflows

| Workflow | Jobs | Purpose | Inputs and secrets |
|---|---|---|---|
| `docs.yml` | `docs` | markdownlint, lychee, `mkdocs build --strict` | [docs.yml](../configuration.md#docsyml) |
| `security-lite.yml` | `gitleaks`, `trivy`, `semgrep`, `checkov` | Secrets, vulnerabilities, misconfigurations, SAST; SARIF to code scanning | [security-lite.yml](../configuration.md#security-liteyml) |
| `scorecard.yml` | `Scorecard analysis` | OpenSSF Scorecard, SARIF to code scanning | [scorecard.yml](../configuration.md#scorecardyml) |
| `packer-build.yml` | `build <image>` | Packer build with mesh access, reports artifact, manifest output | [packer-build.yml](../configuration.md#packer-buildyml) |
| `tofu-gitlab-state.yml` | `<command> <state>` | fmt, validate, tflint, plan, conftest, PR comment, apply | [tofu-gitlab-state.yml](../configuration.md#tofu-gitlab-stateyml) |
| `mirror-to-gitlab.yml` | `mirror` | Branches and tags to GitLab | [mirror-to-gitlab.yml](../configuration.md#mirror-to-gitlabyml) |

## Composite actions

| Action | Purpose | Inputs |
|---|---|---|
| `export-env` | Export listed variables and secrets to the job environment | [export-env](../configuration.md#export-env) |
| `setup-mesh` | Connect the runner to the private network (WireGuard) | [setup-mesh](../configuration.md#setup-mesh) |
| `setup-tofu-http-backend` | `TF_HTTP_*` for GitLab-managed state | [setup-tofu-http-backend](../configuration.md#setup-tofu-http-backend) |
| `pr-comment` | Create or update one pull request comment | [pr-comment](../configuration.md#pr-comment) |

## Repository CI

| Workflow | Trigger | Jobs | Purpose |
|---|---|---|---|
| `validate.yml` | push to `master`, pull request, manual | `linters` | shellcheck, yamllint, actionlint, zizmor, gitleaks |
| `self-test.yml` | push to `master`, pull request, manual | `docs / docs`, `security-lite / *`, `scorecard / Scorecard analysis`, `actions` | Calls the scanning workflows on this repository; tests actions: expected values and rejection of invalid input |
| `repo-scorecard.yml` | push to `master`, weekly, ruleset change | `scorecard / Scorecard analysis` | Published Scorecard results of this repository |
