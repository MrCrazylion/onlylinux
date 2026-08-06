# Only Linux packaging policy

Only Linux maintains independent package recipes and binary repositories.

## Version selection

For packages represented in the latest stable Linux From Scratch systemd
release, LFS is the version authority. The cloud workflow discovers the newest
stable release from the lfs-matrix bundle index; release candidates are
excluded.

A scheduled check runs every day. If the bundle for the newest stable release
already exists in the GitHub Actions cache, the workflow exits without
rebuilding. If it is new, the complete bootstrap workflow starts automatically.

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

LFS package sources are obtained from the complete bundle for the automatically
selected stable release. The cloud workflow verifies the bundle against the
mirror's published `MD5SUMS` file, extracts it into a shared source cache, and
then lets every recipe perform its own declared integrity check.

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

## New-release safety gate

Automatic discovery starts the workflow; it does not silently rewrite package
recipes. Before compilation, the workflow compares every recipe version with
the newly selected LFS metadata and verifies that every required source exists
in the bundle.

If a new LFS release changes a package version or needs a recipe adaptation,
the workflow stops before publishing packages. After the recipes are reviewed
and updated, the next scheduled or manual run completes the build and saves the
new release bundle in the cache.

## Build environment

Official package builds run in clean hosted environments. Generated packages,
repository databases, source caches, and manifests are build-time data and are
not committed to the source repository.
