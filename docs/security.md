# Security

## Guarantees

- Every third-party action is pinned by full commit SHA.
- Every downloaded tool is verified by SHA-256 before use.
- Default `permissions` are read-only or empty; jobs request only what they need.
- Checkout never persists credentials.
- `actionlint`, `zizmor` and `gitleaks` run on every change.

- Infrastructure jobs run only in a caller Environment; `apply` and builds refuse to run outside the default branch.
- Plans are never uploaded; plan files are deleted at the end of the job.
- Exported secrets, the WireGuard key and GitLab tokens are masked in logs.

## Not guaranteed

- Security of the caller: a caller can still grant broad permissions or pass secrets to untrusted code.
- Availability of GitHub-hosted runners and third-party release downloads.

## Assurance case

| Threat | Boundary | Mitigation | CWE |
|---|---|---|---|
| Compromised upstream action changes a tag | third-party actions | pin by SHA, Renovate review | CWE-829 |
| Tampered tool download | release hosting | SHA-256 verification | CWE-494 |
| Script injection through inputs or PR titles | caller → workflow | values passed through `env:`, `zizmor` | CWE-78 |
| Token leakage through checkout | runner workspace | `persist-credentials: false` | CWE-522 |
| Secret in the repository | Git history | gitleaks in pre-commit and CI, push protection | CWE-798 |
| Credential use from a feature branch | Environment | deployment branch policy, default-branch check in the job | CWE-284 |
| Over-broad secret access by a called workflow | caller → workflow | pinned SHA, fixed names only, provider secrets in `ENV_SECRETS`, [ADR 0003](adr/0003-environment-scoped-credentials.md) | CWE-250 |
| Changed release behind a caller | this repository | callers pin SHA; tags are never moved | CWE-829 |
