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

## Update pinned tools

When Renovate bumps `*_VERSION` in a workflow, update the matching `*_SHA256` from the release checksums file
in the same pull request; otherwise the checksum step fails.

## Update locked Python dependencies

Edit `.github/requirements-<name>.in` and regenerate from the repository root (WSL, Python 3.12):

```bash
python3 -m piptools compile --quiet --generate-hashes --allow-unsafe --strip-extras \
  -o .github/requirements-<name>.txt .github/requirements-<name>.in
```
