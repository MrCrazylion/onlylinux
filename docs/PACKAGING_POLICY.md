# Only Linux packaging policy

Only Linux maintains independent package recipes and binary repositories.

## Version selection

For packages represented in Linux From Scratch 13.0 systemd, LFS is the
version authority. Only Linux pins the LFS release used for a distribution
release so that a moving stable alias cannot silently change package versions.

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

LFS package sources are obtained from the complete
`lfs-packages-13.0.tar` bundle mirrored by lfs-matrix. The cloud workflow
downloads the bundle once, verifies it against the mirror's published
`MD5SUMS` file, extracts it into a shared source cache, and then lets every
recipe perform its own declared integrity check.

Recipe URLs remain in each PKGBUILD as documented fallback locations. They are
used only when the matching verified file is absent from the source cache.
Fallback locations are selected in this order:

1. The official upstream release location.
2. An immutable official upstream tag or commit.
3. A source location used and maintained by Arch Linux.
4. The LFS URL when it is valid and points to the expected release.

Every source must be pinned to the selected version and pass its declared
integrity check before building. A broken LFS URL must not change the selected
version and must not be replaced with an unpinned branch.

The cloud build performs a source preflight for the complete package set before
compilation. It verifies that each required filename exists in the LFS bundle,
that recipe versions match LFS 13.0, and that recipe checksums pass.

## Build environment

Official package builds run in clean hosted environments. Generated packages,
repository databases, source caches, and manifests are build-time data and are
not committed to the source repository.
