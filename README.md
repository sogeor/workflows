# workflows

[![CI](https://github.com/sogeor/workflows/actions/workflows/lint.yml/badge.svg)](https://github.com/sogeor/workflows/actions/workflows/lint.yml)
[![Release](https://img.shields.io/github/v/release/sogeor/workflows?sort=semver)](https://github.com/sogeor/workflows/releases)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/sogeor/workflows/badge)](https://scorecard.dev/viewer/?uri=github.com/sogeor/workflows)
[![License: source-available](https://img.shields.io/badge/license-source--available-informational)](LICENSE)

> Reusable GitHub Actions workflows for Sogeor repositories

Shared CI for every repository in the `sogeor` organization: documentation and IaC linting, pull request title checks and releases with release-please. Repositories created from [sogeor/template](https://github.com/sogeor/template) already call these workflows.

## Table of Contents

- [Security](#security)
- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [Development](#development)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Security

Report vulnerabilities privately as described in the [security policy](https://github.com/sogeor/.github/blob/HEAD/SECURITY.md). Secrets in this repository are encrypted with SOPS; never commit them in plain text.

## Background

Keeping CI in one repository means a fix or a version bump lands everywhere at once. Callers pin the major tag `v1`; it moves to the latest `v1.x.y` release after each release. Breaking changes get a new major tag.

| Workflow | Purpose |
|---|---|
| `docs-lint.yml` | markdownlint, REUSE compliance, required files, README section order |
| `lint-iac.yml` | yamllint, gitleaks and Trivy config scan |
| `pr-title.yml` | Conventional Commits check of the pull request title |
| `release.yml` | release-please through the `sogeor-release-bot` GitHub App; outputs `released`, `tag`, `version` |

## Install

Nothing to install. The organization must provide:

- variable `RELEASE_APP_ID` and secret `RELEASE_APP_PRIVATE_KEY` of `sogeor-release-bot`;
- these workflows' actions in the allowed actions list (Organization → Settings → Actions → General).

## Usage

```yaml
jobs:
  lint:
    uses: sogeor/workflows/.github/workflows/docs-lint.yml@v1
  release:
    uses: sogeor/workflows/.github/workflows/release.yml@v1
    secrets: inherit
```

Use the `release` outputs to run publishing jobs only when a release was created:

```yaml
  publish:
    needs: release
    if: needs.release.outputs.released == 'true'
```

## Development

```bash
pre-commit install          # gitleaks, linters, secret checks
pre-commit run --all-files
```

This repository calls its own workflows through local paths (`./.github/workflows/...`), so changes are tested before release.

## Maintainers

[Sogeor maintainers](https://github.com/orgs/sogeor/teams/maintainers)

## Contributing

Issues and pull requests are welcome. Read the [contributing guidelines](https://github.com/sogeor/.github/blob/HEAD/CONTRIBUTING.md) and the [Code of Conduct](https://github.com/sogeor/.github/blob/HEAD/CODE_OF_CONDUCT.md). Pull request titles follow [Conventional Commits](https://www.conventionalcommits.org/); first-time contributors sign the [CLA](https://github.com/sogeor/.github/blob/HEAD/CLA.md).

## License

© 2026 Georgii Sopin. [Sogeor License 1.0](LICENSE) (English and Russian; the Russian version prevails) — you may read the code and contribute, but not copy, redistribute or reuse it.
