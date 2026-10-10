# Workflows and actions

## Reusable workflows

None released yet.

## Composite actions

None released yet.

## Repository CI

| Workflow | Trigger | Jobs | Purpose |
|---|---|---|---|
| `validate.yml` | push to `master`, pull request, manual | `linters` | shellcheck, yamllint, actionlint, zizmor, gitleaks |
| `docs.yml` | push to `master`, pull request, manual | `docs` | markdownlint, lychee, `mkdocs build --strict` |
| `scorecard.yml` | push to `master`, weekly, ruleset change | `Scorecard analysis` | OpenSSF Scorecard, SARIF to code scanning |
