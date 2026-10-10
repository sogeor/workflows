# Configuration

Every input, secret and output of every workflow and action is listed here.

## Reusable workflows

None released yet. Each workflow gets a section with the table
`name | type | default | required | description | example` for inputs, secrets and outputs.

## Repository CI

| Name | Kind | Where | Description |
|---|---|---|---|
| `SCORECARD_TOKEN` | secret | repository | Fine-grained PAT, Administration: read-only; used by `scorecard.yml` |
| `ACTIONLINT_VERSION`, `ACTIONLINT_SHA256` | env | `validate.yml` | actionlint release and archive checksum |
| `GITLEAKS_VERSION`, `GITLEAKS_SHA256` | env | `validate.yml` | gitleaks release and archive checksum |
