# sccache-dist image

This repository builds and publishes the `sccache-dist` runtime image used by the EEHUB K3s cluster.

## What this repository contains

- `Containerfile`: minimal runtime image for `sccache-dist`
- `.github/workflows/image.yml`: GitHub Actions workflow that
  - downloads the official Mozilla `sccache-dist` release tarball
  - verifies it against the published `.sha256` file
  - builds a runtime image
  - smoke-tests the image
  - publishes the image to GHCR
- `VERSION`: the upstream `sccache-dist` version this repository currently packages

## Image path

The workflow publishes to:

- `ghcr.io/zjm54321/sccache-dist:v0.15.0`
- `ghcr.io/zjm54321/sccache-dist:main`
- `ghcr.io/zjm54321/sccache-dist:sha-<gitsha>`

## Upstream verification policy

This repository does **not** build `sccache-dist` from random source tarballs inside Docker.

The workflow downloads the official release asset:

- `sccache-dist-v<version>-x86_64-unknown-linux-musl.tar.gz`

and verifies it using the matching upstream:

- `sccache-dist-v<version>-x86_64-unknown-linux-musl.tar.gz.sha256`

If the checksum file is missing or does not match, the workflow fails before any image build or publish step.

## Runtime expectations

This image is intended for:

- `Deployment/sccache-scheduler`
- `DaemonSet/sccache-build-server`

in the `SHMTU-EEHUB/k3s` GitOps repository.

Operational assumptions:

- the scheduler can run directly from this image
- the build-server also uses this image, but Kubernetes must run it with `privileged: true` and `runAsUser: 0`
- the build-server still relies on node labels and `hostNetwork: true` in the consuming cluster manifests
- this image does **not** provide workload-side `sccache` client binaries for arbitrary application containers

## Workflow behavior

- Pull requests: build + verify only, no publish
- Push to `main`: build, verify, publish `v<VERSION>`, `main`, and `sha-<gitsha>`
- Push tag `v*`: build, verify, publish, and fail if the git tag does not match `VERSION`

## Relationship to shared cache endpoint

This repository only owns the scheduler/build-server runtime image.

The shared S3 cache endpoint remains managed in the cluster repo and should continue to be accessed via:

- `https://sccache.eehub.mingz.top`

## Consumer repo note

The current consumer manifests live in:

- `https://github.com/SHMTU-EEHUB/k3s`

If the image owner/path changes later, update the consuming image references there before the next sync.
