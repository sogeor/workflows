# 0004. Mesh access for CI: WireGuard now, Tailscale later

- Status: proposed
- Date: 2026-10-11

## Context and problem statement

GitHub-hosted runners must reach private hosts (hypervisor API, internal GitLab) without inbound ports at home.
The platform target is Headscale with Tailscale clients; Headscale does not exist yet. The `images`
repository already reaches Proxmox through a WireGuard hub on a VDS.

## Decision outcome

The `setup-mesh` action has a `mode` input. `wireguard` moves the existing approach from `images` into this
repository with all addresses supplied as variables; `tailscale` is reserved and fails until Headscale exists.
After the switch, callers change `mode` and variables only.

### Consequences

- One implementation of runner access for all repositories.
- The WireGuard hub is a single point of failure for CI access, as before.
- If WireGuard is blocked, AmneziaWG is the fallback (platform ADR).
