# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [SemVer](https://semver.org/).

## [Unreleased]

### Added

- Reusable workflows: `docs` (markdownlint, lychee, MkDocs), `security-lite` (gitleaks, Trivy, Semgrep, Checkov,
  SARIF upload), `scorecard` (OpenSSF Scorecard with optional publishing).
- `self-test` calls every reusable workflow on this repository; `repo-scorecard` publishes this repository's Scorecard.
- Renovate regex manager for container images pinned by digest.
- Repository scaffold: community files, issue and pull request templates, CODEOWNERS.
- CI: `validate.yml` (shellcheck, yamllint, actionlint, zizmor, gitleaks).
- pre-commit, Renovate, hash-locked Python tools.
- Documentation to the platform standard, MkDocs site, ADR 0001–0002.
