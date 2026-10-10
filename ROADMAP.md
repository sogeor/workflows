# Roadmap

Horizon: through Q4 2027. Order follows the sogeor platform plan.

## Planned

- `v0.1.0`: reusable `docs`, `security-lite`, `scorecard` workflows and `self-test`.
- `v0.2.0`: `tofu-gitlab-state`, `packer-build`, `mirror-to-gitlab` workflows;
  `setup-tofu-http-backend`, `setup-mesh` (WireGuard), `pr-comment` actions.
- `images` switches to `packer-build` and `setup-mesh`.
- `ansible-lint` and `gitops-validate` workflows, once the `ansible` and `platform` repositories exist.
- `setup-mesh` Tailscale mode against Headscale; WireGuard mode removed afterwards.

## Not planned

- Floating major tags (`v1`): callers pin exact releases.
- Self-hosted runners.
- Workflows for CI systems other than GitHub Actions (GitLab templates live in `ci-templates`).
