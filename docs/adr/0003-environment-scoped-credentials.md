# 0003. Environment-scoped credentials with fixed names

- Status: proposed
- Date: 2026-10-11

## Context and problem statement

Infrastructure workflows need credentials that must only be usable from the default branch.
GitHub restricts this per Environment, but a caller cannot pass Environment secrets through `secrets:`:
the `workflow_call` trigger has no `environment` key, so only the called job can select the Environment.
Provider credentials also differ per caller (Proxmox, OpenStack, Cloudflare).

## Considered options

1. Explicit `secrets:` declared by every workflow; credentials stored at repository level.
2. The called job selects the caller's Environment (input `environment`), reads fixed names for
   the workflow's own needs, and exports provider credentials listed by name.

## Decision outcome

Option 2. The caller passes `secrets: inherit`; branch restrictions of the Environment protect the values.
Backend, mesh and mirror credentials use fixed names documented in Configuration; provider credentials are
listed in `env-vars` / `env-secrets` and exported by the `export-env` action, which reads `toJSON(secrets)`.

### Consequences

- Credentials work only where the Environment allows (default branch, required reviewers if configured).
- The called workflow can see all secrets of the caller; acceptable because it is pinned by SHA and
  maintained by the same organization. zizmor `overprovisioned-secrets` is suppressed at these two lines.
- Renaming a fixed name is a breaking change (new major version).
