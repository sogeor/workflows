# Usage

Replace `<sha>` and `vX.Y.Z` with a release of this repository. All inputs are in [Configuration](configuration.md).

## Documentation checks

`.github/workflows/docs.yml` in the caller:

```yaml
name: docs

on:
  pull_request:
  push:
    branches: [master]

permissions:
  contents: read

jobs:
  docs:
    uses: sogeor/workflows/.github/workflows/docs.yml@<sha> # vX.Y.Z
    with:
      link-args: --exclude '^https://github\.com/<owner>/<repo>/security'
```

The required status check is named `docs / docs`.

## Security scans

```yaml
name: security

on:
  pull_request:
  push:
    branches: [master]
  schedule:
    - cron: "0 3 * * 1"

permissions:
  contents: read

jobs:
  security:
    uses: sogeor/workflows/.github/workflows/security-lite.yml@<sha> # vX.Y.Z
    permissions:
      contents: read
      security-events: write
    with:
      checkov: true
      checkov-frameworks: terraform,github_actions
      upload-sarif: ${{ github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository }}
```

Status checks: `security / gitleaks`, `security / trivy`, `security / semgrep`, `security / checkov`.

## Scorecard

```yaml
name: scorecard

on:
  branch_protection_rule:
  schedule:
    - cron: "17 4 * * 1"
  push:
    branches: [master]

permissions: {}

jobs:
  scorecard:
    uses: sogeor/workflows/.github/workflows/scorecard.yml@<sha> # vX.Y.Z
    permissions:
      contents: read
      actions: read
      security-events: write
      id-token: write
    secrets:
      scorecard-token: ${{ secrets.SCORECARD_TOKEN }}
```

Badge: `https://api.scorecard.dev/projects/github.com/<owner>/<repo>/badge`.
