# Getting started

Two paths: a scanning workflow (no credentials, five minutes) and an infrastructure workflow
(an Environment with credentials, a plan in a pull request).

## Prerequisites

- A GitHub repository with Actions enabled; you are its administrator.
- A release of this repository (`vX.Y.Z`) and the full commit SHA of its tag.

Find the SHA: open [Releases](https://github.com/sogeor/workflows/releases), click the tag, copy the commit SHA, or run

```bash
git ls-remote https://github.com/sogeor/workflows refs/tags/vX.Y.Z
```

## Path 1: documentation checks

1. Create `.github/workflows/docs.yml` in your repository:

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
        uses: sogeor/workflows/.github/workflows/docs.yml@<full-sha> # vX.Y.Z
        with:
          mkdocs: false
    ```

2. Push a branch and open a pull request.

**Expected result:** the check `docs / docs` runs markdownlint and lychee and passes.

**How to check:** **Actions** tab → the run → job `docs / docs` → steps `markdownlint` and `lychee` are green.

With an MkDocs site, remove `mkdocs: false` and commit a hash-locked `.github/requirements-docs.txt`
([Configuration](configuration.md#docsyml)).

## Path 2: OpenTofu plan in a pull request

Goal: every pull request that changes `live/example` gets a plan comment; state lives in GitLab.

### Prepare

1. On gitlab.com create a project for state (for example `tfstate`); note its numeric **Project ID**
   (**Settings → General**).
2. Create a personal access token on gitlab.com: **Edit profile → Access tokens → Add new token**, scope `api`.
   The user needs the Maintainer role in the project.
3. Generate a state encryption passphrase and store it in your password manager:

    ```bash
    openssl rand -base64 32
    ```

4. The root module declares an empty http backend and state encryption:

    ```hcl
    terraform {
      backend "http" {}
    }
    ```

    together with `encryption` that uses `var.state_passphrase` (see the
    [OpenTofu state encryption docs](https://opentofu.org/docs/language/state/encryption/)).

### Create the Environment

In your repository: **Settings → Environments → New environment** `example-plan`, then add:

| Kind | Name | Value |
|---|---|---|
| Variable | `GITLAB_TFSTATE_PROJECT_ID` | Project ID from step 1 |
| Variable | `GITLAB_TFSTATE_USERNAME` | GitLab user name |
| Secret | `GITLAB_TFSTATE_TOKEN` | Token from step 2 |
| Secret | `STATE_PASSPHRASE` | Passphrase from step 3 |
| Secret | `ENV_SECRETS` | Provider credentials, one `NAME=value` per line, for example `TF_VAR_api_token=CHANGE_ME` |

Values without leading or trailing spaces.

### Call the workflow

`.github/workflows/example.yml`:

```yaml
name: example

on:
  pull_request:
    paths: [live/example/**]

permissions:
  contents: read

jobs:
  plan:
    if: github.event.pull_request.head.repo.full_name == github.repository
    uses: sogeor/workflows/.github/workflows/tofu-gitlab-state.yml@<full-sha> # vX.Y.Z
    secrets: inherit
    permissions:
      contents: read
      pull-requests: write
    with:
      command: plan
      working-directory: live/example
      state-name: example
      environment: example-plan
```

**Expected result:** job `plan / plan example` passes and the pull request gets a comment
**OpenTofu plan: `example`** with the plan. A new push updates the same comment.

**How to check:** the comment exists; the job log shows `http backend: https://gitlab.com/api/v4/projects/<id>/terraform/state/example`;
the state appears in GitLab under **Operate → Terraform states** after the first apply.

For `apply`, a mesh and Packer builds see [Usage](usage.md); every input is in [Configuration](configuration.md).

## If it did not work

See [Troubleshooting](troubleshooting.md).
