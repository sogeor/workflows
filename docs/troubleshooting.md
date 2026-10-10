# Troubleshooting

## `sha256sum: WARNING: 1 computed checksum did NOT match`

- **Cause:** a tool version was bumped without updating its `*_SHA256`.
- **Fix:** take the checksum from the release checksums file and update the variable
  ([Operations](operations.md#update-pinned-tools)).

## `workflow was not found` when calling a reusable workflow

- **Cause:** wrong path or SHA, or the caller is private and access is not granted.
- **Fix:** check the path `.github/workflows/<name>.yml@<sha>`; see [Repository setup](setup.md#access-for-callers).
