# Only Linux packaging policy

Only Linux maintains independent package recipes and binary repositories.

## Version selection

For packages represented in the stable Linux From Scratch release, LFS is the
version authority. The LFS download URL is metadata, not a mandatory source
location.

Packages outside LFS follow the Only Linux fixed-release policy and use stable
upstream releases selected for the target release.

## Recipe sources

Arch Linux packaging is the preferred engineering reference for build flags,
dependencies, package layout, patches, and compatibility decisions. Every
recipe is copied into and maintained by Only Linux; Only Linux does not consume
Arch binary repositories as distribution repositories.

Arch recipes are adapted when their version, dependency model, patches, or
configuration are specific to Arch or conflict with the Only Linux release.

## Source selection and integrity

Source locations are selected in this order:

1. The official upstream release location.
2. An immutable official upstream tag or commit.
3. A source location used and maintained by Arch Linux.
4. The LFS URL when it is valid and points to the expected release.

Every source must be pinned to the selected version and pass its declared
integrity check before building. A broken LFS URL must not change the selected
version and must not be replaced with an unpinned branch.

The cloud build performs a source preflight for the complete package set before
compilation. This catches missing files, HTML error responses, and checksum
mismatches early.

## Build environment

Official package builds run in clean hosted environments. Generated packages,
repository databases, and manifests are published as build artifacts and are
not committed to the source repository.
