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
   the workflow's own needs, and exports provider credentials listed by name through `toJSON(secrets)`.
3. As option 2, but provider secrets are lines `NAME=value` of one fixed secret `ENV_SECRETS`.
4. As option 2, but the workflow reads a fixed list of secret names for every supported provider.

## Decision outcome

Option 3. The caller passes `secrets: inherit`; branch restrictions of the Environment protect the values.
Backend, mesh and mirror credentials use fixed names documented in Configuration; provider settings are
variables listed in `env-vars`, provider secrets are lines of `ENV_SECRETS`, exported and masked by `export-env`.
Option 2 exposed every secret of the caller to the job (CodeQL "Excessive Secrets Exposure");
option 4 requires a release of this repository for every new provider.

### Consequences

- Credentials work only where the Environment allows (default branch, required reviewers if configured).
- The job reads only the secrets it names; new providers need no change here.
- Rotating one provider secret means entering the whole `ENV_SECRETS` value again.
- Renaming a fixed name is a breaking change (new major version).
