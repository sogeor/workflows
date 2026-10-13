# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [SemVer](https://semver.org/).

## [Unreleased]

### Changed

- Troubleshooting: Scorecard publishing from `scorecard.yml` is confirmed to work; the entry lists the
  requirements for the caller workflow instead of suggesting that reusable workflows are rejected.

### Added

- Troubleshooting: Environment variables and secrets are not interchangeable.

## [0.1.1] - 2026-10-11

### Added

- Getting started for infrastructure workflows: GitLab state, Environment, plan comment in a pull request.
- Operations runbooks: credential rotation in caller Environments (including `ENV_SECRETS`), WireGuard key
  rotation, breaking-change releases.
- `self-test`: negative cases for every composite action (malformed `ENV_SECRETS` lines, reserved names,
  missing variables, non-numeric project ID, plain `http`, missing WireGuard settings, invalid comment marker).

### Changed

- ADR 0002–0005 accepted.
- Contributing guide describes how actions and infrastructure workflows are tested.

### Removed

- References to the non-existent `tests/fixtures/` directory.

## [0.1.0] - 2026-10-11

First release.

### Added

- Reusable workflows:
  - `docs`: markdownlint, lychee (GitHub `/blob/` links checked through `raw.githubusercontent.com`,
    temporary 429 and 502–504 answers accepted), `mkdocs build --strict`;
  - `security-lite`: gitleaks, Trivy, Semgrep, Checkov, SARIF upload to code scanning;
  - `scorecard`: OpenSSF Scorecard with optional publishing;
  - `packer-build`: Packer build in a caller Environment with mesh access, CA trust, reports artifact and
    a manifest output;
  - `tofu-gitlab-state`: OpenTofu with GitLab-managed state — fmt, validate, tflint, plan with a pull request
    comment and Conftest, apply from the default branch only;
  - `mirror-to-gitlab`: branches and tags pushed to GitLab.
- Composite actions: `export-env` (variables by name, secrets from the dotenv secret `ENV_SECRETS`),
  `setup-mesh` (WireGuard), `setup-tofu-http-backend`, `pr-comment`.
- `self-test` calls the scanning workflows on this repository and checks the composite actions;
  `repo-scorecard` publishes this repository's Scorecard.
- Tools pinned by version and SHA-256 or image digest; Renovate managers for tool versions and image digests.
- Repository scaffold: community files, issue and pull request templates, CODEOWNERS, `validate.yml`
  (shellcheck, yamllint, actionlint, zizmor, gitleaks), pre-commit, hash-locked Python tools.
- Documentation to the platform standard, MkDocs site, ADR 0001–0005.

[Unreleased]: https://github.com/sogeor/workflows/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/sogeor/workflows/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/sogeor/workflows/releases/tag/v0.1.0
