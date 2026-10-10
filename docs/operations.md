# Operations

## Release

1. Merge the changes to `master`; move `Unreleased` entries in `CHANGELOG.md` to a new `[X.Y.Z]` section.
2. Create a signed tag and a GitHub Release with the CHANGELOG excerpt:

    ```bash
    git tag -s vX.Y.Z -m vX.Y.Z
    git push origin vX.Y.Z
    ```

3. Breaking changes to inputs, secrets or outputs require a new major version.

## Update callers

Renovate in each caller opens a pull request that changes the SHA and the version comment. Review the CHANGELOG and merge.

## Rollback

Pin the caller back to the SHA of the previous release. Tags are never moved or deleted.

## Rotate credentials in a caller Environment

Goal: replace a credential without failed runs.

1. Create the new credential at the provider (token, password, key); keep the old one valid.
2. In the caller repository: **Settings → Environments → `<environment>`**.
3. For a fixed-name secret (`GITLAB_TFSTATE_TOKEN`, `WG_RUNNER_PRIVATE_KEY`, …): **Edit** → paste the new value → **Update secret**.
4. For a provider credential: **`ENV_SECRETS` → Edit** and enter **all** lines again with the changed value;
   GitHub never shows the old value, so keep the list of names in the repository documentation of the caller.
5. Run the workflow (`workflow_dispatch` or a pull request for plans).
6. When the run passes, revoke the old credential at the provider.

**How to check:** the job log shows `exported secret <NAME>` for every expected name and no authentication errors.

`STATE_PASSPHRASE` is special: changing it requires the `fallback` block of OpenTofu state encryption;
follow the runbook of the repository that owns the state.

## Rotate the WireGuard key of runners

1. Generate a key pair: `wg genkey | tee runner.key | wg pubkey > runner.pub`.
2. Replace the runner peer public key on the hub.
3. Update `WG_RUNNER_PRIVATE_KEY` in every Environment that uses `mesh: wireguard`, then delete `runner.key`.

## Release a breaking change

1. Describe the change under **Changed** with a **Breaking** marker in `CHANGELOG.md`, including the migration.
2. Increase the major version (`v1.0.0`; before `v1.0.0` the minor version: `v0.3.0`).
3. Update the examples in [Usage](usage.md) and [Getting started](getting-started.md).

## Update pinned tools

When Renovate bumps `*_VERSION` in a workflow, update the matching `*_SHA256` from the release checksums file
in the same pull request; otherwise the checksum step fails.

## Update locked Python dependencies

Edit `.github/requirements-<name>.in` and regenerate from the repository root (WSL, Python 3.12):

```bash
python3 -m piptools compile --quiet --generate-hashes --allow-unsafe --strip-extras \
  -o .github/requirements-<name>.txt .github/requirements-<name>.in
```
