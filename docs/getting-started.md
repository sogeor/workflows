# Getting started

Goal: call a reusable workflow from your repository.

## Prerequisites

- A GitHub repository with Actions enabled.
- A release of this repository (`vX.Y.Z`) and its full commit SHA.

## Steps

1. Find the release on [Releases](https://github.com/sogeor/workflows/releases) and copy the commit SHA of its tag.
2. Add a job that calls the workflow, pinned by SHA with the tag in a comment:

    ```yaml
    jobs:
      docs:
        uses: sogeor/workflows/.github/workflows/docs.yml@<full-sha> # vX.Y.Z
        permissions:
          contents: read
    ```

3. Pass inputs and secrets as described in [Configuration](configuration.md).
4. Push and open a pull request.

## Expected result

The job appears in the run of your workflow as `<caller job> / <called job>` and passes.

## How to check

**Actions** tab of your repository → the run → the called job shows the steps of the reusable workflow.

## If it did not work

See [Troubleshooting](troubleshooting.md).
