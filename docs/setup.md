# Repository setup

Settings for this repository (or a fork of it).

## Repository settings

**Settings → General**:

| Field | Value |
|---|---|
| Description | Reusable GitHub Actions workflows and composite actions for the sogeor DevSecOps platform: pinned, least-privilege CI building blocks. |
| Website | empty until the documentation site exists |
| Topics | `github-actions`, `reusable-workflows`, `composite-actions`, `ci-cd`, `devsecops`, `supply-chain-security`, `security-hardening`, `openssf-scorecard`, `renovate`, `mkdocs`, `platform-engineering` |

**Include in the home page:** Releases — on after the first release; Deployments — off; Packages — off.

**Settings → General → Pull Requests:** only **Allow squash merging**; enable **Automatically delete head branches**.

## Access for callers

**Settings → Actions → General → Access:** the repository is public, so public callers can use it without changes.
For private repositories of the same organization select
**Accessible from repositories in the 'sogeor' organization**.

## Ruleset

**Settings → Rules → Rulesets → New branch ruleset**:

1. Name `master`, Enforcement status **Active**, target branch **Default**.
2. Enable **Restrict deletions**, **Require signed commits**, **Require a pull request before merging** (0 approvals),
   **Block force pushes**.
3. **Require status checks to pass**, **Require branches to be up to date**; add `linters` and `docs`.
4. **Bypass list:** Repository admin, mode **For pull requests only**.

## Advanced Security

**Settings → Advanced Security**: Private vulnerability reporting — on; Dependency graph — on;
Dependabot alerts — on; Dependabot security and version updates — off (Renovate is used);
Secret Protection and Push protection — on; CodeQL analysis — **Default setup** with language `actions`.

## Renovate

Install the Renovate GitHub App for this repository (**Only select repositories**). The configuration is in `renovate.json`.

## Scorecard

1. Create a fine-grained personal access token: resource owner `sogeor`, repository `workflows`,
   permission **Administration: Read-only**, expiration 1 year.
2. **Settings → Secrets and variables → Actions → New repository secret**: name `SCORECARD_TOKEN`, value — the token.
