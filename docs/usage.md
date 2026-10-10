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

## Packer build (Proxmox over WireGuard)

Environment `images`: variables `PROXMOX_URL`, `PROXMOX_USERNAME`, `PROXMOX_CA_PEM` and the mesh variables;
secrets `WG_RUNNER_PRIVATE_KEY` and `ENV_SECRETS` with the line `PROXMOX_TOKEN=CHANGE_ME`.

```yaml
name: build

on:
  schedule:
    - cron: "0 3 1 * *"
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: packer-build-proxmox
  cancel-in-progress: false

jobs:
  base:
    uses: sogeor/workflows/.github/workflows/packer-build.yml@<sha> # vX.Y.Z
    secrets: inherit
    with:
      environment: images
      image: ubuntu-2404-base
      install-command: tools/ci-install.sh
      ca-pem-var: PROXMOX_CA_PEM
      mesh: wireguard
      manifest-file: manifest/ubuntu-2404-base.json
      manifest-query: .builds[-1].custom_data.template_name

  k8s:
    needs: base
    uses: sogeor/workflows/.github/workflows/packer-build.yml@<sha> # vX.Y.Z
    secrets: inherit
    with:
      environment: images
      image: ubuntu-2404-k8s
      install-command: tools/ci-install.sh
      ca-pem-var: PROXMOX_CA_PEM
      mesh: wireguard
      packer-vars: |
        base_template=${{ needs.base.outputs.result }}
      manifest-file: manifest/ubuntu-2404-k8s.json
      manifest-query: .builds[-1].custom_data.template_name
```

## OpenTofu plan and apply

```yaml
name: mgmt

on:
  pull_request:
    paths: [live/mgmt/**]
  push:
    branches: [master]
    paths: [live/mgmt/**]

permissions:
  contents: read

jobs:
  plan:
    if: github.event_name == 'pull_request'
    uses: sogeor/workflows/.github/workflows/tofu-gitlab-state.yml@<sha> # vX.Y.Z
    secrets: inherit
    permissions:
      contents: read
      pull-requests: write
    with:
      command: plan
      working-directory: live/mgmt
      state-name: mgmt
      environment: mgmt-plan
      conftest-policy: policies/conftest
      mesh: wireguard

  apply:
    if: github.event_name == 'push'
    uses: sogeor/workflows/.github/workflows/tofu-gitlab-state.yml@<sha> # vX.Y.Z
    secrets: inherit
    permissions:
      contents: read
      pull-requests: write
    with:
      command: apply
      working-directory: live/mgmt
      state-name: mgmt
      environment: mgmt
      conftest-policy: policies/conftest
      mesh: wireguard
```

Provider secrets go to `ENV_SECRETS` of the `mgmt-plan` and `mgmt` Environments, for example
`TF_VAR_proxmox_api_token=CHANGE_ME`.

Pull requests from forks get no Environment secrets: run `plan` only for branches of the same repository
(`github.event.pull_request.head.repo.full_name == github.repository`).

## Mirror to GitLab

```yaml
name: mirror

on:
  push:
    branches: ["**"]
    tags: ["**"]
  delete:

permissions:
  contents: read

jobs:
  mirror:
    uses: sogeor/workflows/.github/workflows/mirror-to-gitlab.yml@<sha> # vX.Y.Z
    secrets: inherit
    with:
      environment: mirror
      mesh: wireguard
```

The `mirror` Environment needs no branch restriction for branch pushes; restrict it to the default branch
if only `master` and tags should be mirrored (and trigger on them only).

## Actions in your own jobs

```yaml
steps:
  - uses: sogeor/workflows/actions/setup-mesh@<sha> # vX.Y.Z
    with:
      mode: wireguard
      wg-private-key: ${{ secrets.WG_RUNNER_PRIVATE_KEY }}
      wg-server-public-key: ${{ vars.WG_SERVER_PUBLIC_KEY }}
      wg-endpoint: ${{ vars.WG_ENDPOINT }}
      wg-address: ${{ vars.WG_ADDRESS }}
      wg-allowed-ips: ${{ vars.WG_ALLOWED_IPS }}
      check-address: ${{ vars.MESH_CHECK_ADDRESS }}
```
