# sogeor workflows

Reusable GitHub Actions workflows and composite actions shared by the repositories of the
[sogeor](https://github.com/sogeor) platform.

## Who it is for

- Maintainers of sogeor repositories who need the same CI steps everywhere.
- Anyone adopting the platform who wants hardened, pinned CI building blocks.

## Place in the platform

The external CI loop of the platform runs on GitHub-hosted runners. Repositories such as
[images](https://github.com/sogeor/images) and `management` call workflows from here instead of copying them.
The internal loop (GitLab in the management cluster) uses `ci-templates` instead.

## Contents

| Kind | Name | Status |
|---|---|---|
| Workflow | `docs`, `security-lite`, `scorecard`, `self-test` | planned for `v0.1.0` |
| Workflow | `tofu-gitlab-state`, `packer-build`, `mirror-to-gitlab` | planned for `v0.2.0` |
| Action | `setup-tofu-http-backend`, `setup-mesh`, `pr-comment` | planned for `v0.2.0` |
| Workflow | `ansible-lint`, `gitops-validate` | later, see [roadmap](https://github.com/sogeor/workflows/blob/master/ROADMAP.md) |

The current list is in [Reference](reference/workflows.md).
