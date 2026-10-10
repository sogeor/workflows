# Contributing

## Process

1. Open an [issue](https://github.com/sogeor/workflows/issues) for bugs and feature requests
   (English or Russian). Report vulnerabilities privately per [SECURITY.md](SECURITY.md).
2. Create a branch `feat/...`, `fix/...`, `docs/...` or `chore/...` and open a pull request to `master`.
3. Requirements for a pull request to be accepted:
   - [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) messages;
   - signed commits;
   - all required checks green (`linters`, `docs`);
   - `README.md`, `CHANGELOG.md` and the page of every changed workflow or action updated;
   - an ADR in [`docs/adr/`](docs/adr/index.md) (status `proposed`) for architectural changes.

By contributing you agree that your contribution is licensed under [Apache-2.0](LICENSE).

## Tests

- Every reusable workflow and composite action is exercised by `self-test`.
- A new input or behavior comes with a fixture in `tests/fixtures/` that covers it.
- Fixed defects get a fixture that would have caught them.

## Coding standards

| Language | Standard | Enforced by |
|---|---|---|
| GitHub Actions | Actions pinned by full SHA with a version comment; minimal `permissions`; `persist-credentials: false`; inputs reach `run:` only through `env:` | `actionlint`, `zizmor` |
| Shell | [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html); `#!/usr/bin/env bash`, `set -euo pipefail` | `shellcheck` |
| YAML | 2-space indent, `.yamllint` | `yamllint --strict` |
| Markdown | `.markdownlint.yaml` | `markdownlint-cli2` |

All documentation, comments and messages are in English.

## Local setup

```bash
git clone https://github.com/sogeor/workflows.git
cd workflows
pre-commit install
pre-commit run --all-files
```

Python dependencies are hash-locked; to change one, edit the `.in` file and regenerate the lock file
(keep the pip-compile header):

```bash
python3 -m piptools compile --quiet --generate-hashes --allow-unsafe --strip-extras \
  -o .github/requirements-lint.txt .github/requirements-lint.in
```

Requires Python 3.12 and `pre-commit`.
