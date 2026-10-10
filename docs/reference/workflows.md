# Workflows and actions

## Reusable workflows

| Workflow | Jobs | Purpose | Inputs and secrets |
|---|---|---|---|
| `docs.yml` | `docs` | markdownlint, lychee, `mkdocs build --strict` | [docs.yml](../configuration.md#docsyml) |
| `security-lite.yml` | `gitleaks`, `trivy`, `semgrep`, `checkov` | Secrets, vulnerabilities, misconfigurations, SAST; SARIF to code scanning | [security-lite.yml](../configuration.md#security-liteyml) |
| `scorecard.yml` | `Scorecard analysis` | OpenSSF Scorecard, SARIF to code scanning | [scorecard.yml](../configuration.md#scorecardyml) |

## Composite actions

None released yet.

## Repository CI

| Workflow | Trigger | Jobs | Purpose |
|---|---|---|---|
| `validate.yml` | push to `master`, pull request, manual | `linters` | shellcheck, yamllint, actionlint, zizmor, gitleaks |
| `self-test.yml` | push to `master`, pull request, manual | `docs / docs`, `security-lite / *`, `scorecard / Scorecard analysis` | Calls every reusable workflow on this repository |
| `repo-scorecard.yml` | push to `master`, weekly, ruleset change | `scorecard / Scorecard analysis` | Published Scorecard results of this repository |
