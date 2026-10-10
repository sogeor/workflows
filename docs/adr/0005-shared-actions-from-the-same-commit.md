# 0005. Reusable workflows use actions from the same commit

- Status: proposed
- Date: 2026-10-11

## Context and problem statement

Reusable workflows of this repository use its composite actions. `uses: ./actions/...` resolves in the
caller's checkout, and `uses: sogeor/workflows/actions/...@<sha>` cannot point to the commit that contains it.

## Decision outcome

The job checks out this repository at `job.workflow_sha` into `.shared-workflows` (the repository is taken
from `job.workflow_ref`, so forks work) and uses `./.shared-workflows/actions/<name>`.

### Consequences

- A workflow and its actions always come from the same commit.
- One extra checkout per job.
- actionlint 1.7.12 does not know `job.workflow_ref`/`job.workflow_sha`; the error is ignored in
  `.github/actionlint.yaml` until it does.
- `job.workflow_*` is not available on GitHub Enterprise Server.
