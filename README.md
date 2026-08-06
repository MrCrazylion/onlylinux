# Only Linux

**Only Linux** is an independent, general-purpose, fixed-release Linux distribution that aims to provide a clean, stable, and consistent platform for everyday use and a wide range of workloads.

It features:

- GNOME as the official desktop environment
- Tatami as the package manager
- Independently maintained package repositories
- Fixed releases instead of a rolling-release model
- A core package set whose versions are selected with guidance from Linux From Scratch
- Package-building infrastructure based on proven Linux packaging technologies

## Vision

Only Linux is not intended to be a gaming distribution, developer distribution, security distribution, or specialized workstation.

Its goal is to be a general operating system that tries to be simply Linux.

The project focuses on:

- Stability
- Simplicity
- Consistency
- General-purpose use
- Minimal unnecessary customization
- Clear release and update policies
- Independence from another distribution's repositories

## Project status

Only Linux is currently in the early design and bootstrap stage.

The first development goals are:

1. Define the core package set.
2. Import package versions from Linux From Scratch 13.0 systemd.
3. Maintain independent package recipes.
4. Build packages automatically in clean environments.
5. Create signed Only Linux repositories.
6. Develop the Tatami package manager using libalpm.
7. Build a minimal bootable system.
8. Add the GNOME desktop.
9. Produce the first installation image.

## Package model

Only Linux uses a layered package model.

### Core

Core package versions are selected using the pinned Linux From Scratch 13.0 systemd release as the version authority. Arch Linux packaging is used as the preferred engineering reference for recipes.

LFS sources are downloaded as one verified source bundle. Official upstream locations remain in the recipes as fallback sources.

See [the packaging policy](docs/PACKAGING_POLICY.md) for the source fallback and integrity rules.

### System and desktop

System components, GNOME, and desktop technologies are selected from their stable upstream releases and built against the Only Linux core.

### Additional software

Additional packages are maintained independently and built for Only Linux repositories.

## Build infrastructure

Package builds run automatically in clean environments on GitHub-hosted infrastructure. Developers do not need to build the distribution directly on their personal computers.

## Repository layout

```text
onlylinux/
├── .github/
│   └── workflows/
│       ├── test-build.yml
│       └── build-core-bootstrap.yml
├── config/
│   ├── release.yaml
│   └── core-packages.yaml
├── docs/
│   └── PACKAGING_POLICY.md
├── manifests/
│   └── README.md
├── packages/
│   └── core/
│       ├── filesystem/PKGBUILD
│       ├── attr/PKGBUILD
│       ├── acl/PKGBUILD
│       ├── libcap/PKGBUILD
│       ├── libxcrypt/PKGBUILD
│       ├── zlib/PKGBUILD
│       ├── xz/PKGBUILD
│       ├── zstd/PKGBUILD
│       ├── bzip2/PKGBUILD
│       ├── ncurses/PKGBUILD
│       ├── readline/PKGBUILD
│       ├── bash/PKGBUILD
│       ├── m4/PKGBUILD
│       ├── file/PKGBUILD
│       ├── diffutils/PKGBUILD
│       ├── coreutils/PKGBUILD
│       ├── sed/PKGBUILD
│       ├── grep/PKGBUILD
│       ├── gawk/PKGBUILD
│       ├── findutils/PKGBUILD
│       ├── gzip/PKGBUILD
│       ├── make/PKGBUILD
│       ├── patch/PKGBUILD
│       └── tar/PKGBUILD
├── scripts/
│   ├── import_lfs.py
│   ├── prepare_lfs_sources.sh
│   └── build_bootstrap.sh
├── .gitignore
├── LICENSE
└── README.md
```

Generated build products and source caches are written under `output/` and `.cache/` on GitHub-hosted runners and are not committed to the repository. The generated `manifests/lfs-packages.json` file is included in workflow artifacts.

## Bootstrap pipeline

The bootstrap pipeline:

1. Imports the pinned LFS 13.0 metadata.
2. Restores the LFS source bundle from the GitHub Actions cache when available.
3. Downloads `lfs-packages-13.0.tar` only when the cache is empty.
4. Verifies the complete bundle against its published checksum.
5. Confirms that every required source is present and every recipe version matches LFS.
6. Builds twenty-four packages inside an Arch Linux container.

The current package set is:

- `filesystem`
- `attr`
- `acl`
- `libcap`
- `libxcrypt`
- `zlib`
- `xz`
- `zstd`
- `bzip2`
- `ncurses`
- `readline`
- `bash`
- `m4`
- `file`
- `diffutils`
- `coreutils`
- `sed`
- `grep`
- `gawk`
- `findutils`
- `gzip`
- `make`
- `patch`
- `tar`

The workflow then creates an `only-core` ALPM repository database and uploads the complete repository as a GitHub Actions artifact.

## Current scope

This repository contains the initial project definition and bootstrap automation. It does not yet provide an installable operating system.
