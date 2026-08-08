# Only Linux

**Only Linux** is an independent, general-purpose Linux distribution that aims to provide a clean, stable, and consistent platform for everyday use and a wide range of workloads.

It features:

- GNOME as the official desktop environment
- Tatami as the package manager
- Independently maintained package repositories
- Controlled releases instead of directly consuming a rolling binary repository
- A core package set whose versions follow stable Linux From Scratch releases
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
2. Track the latest stable Linux From Scratch systemd release.
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

Core package versions use the latest stable Linux From Scratch systemd release as the version authority. Arch Linux packaging is the preferred engineering reference for recipes.

The cloud workflow discovers new stable LFS source bundles automatically. Official upstream locations remain in the recipes as fallback sources.

See [the packaging policy](docs/PACKAGING_POLICY.md) for the source fallback, integrity, and new-release safety rules.

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
│       ├── tar/PKGBUILD
│       ├── gmp/PKGBUILD
│       ├── mpfr/PKGBUILD
│       ├── mpc/PKGBUILD
│       ├── bison/PKGBUILD
│       ├── flex/PKGBUILD
│       ├── bc/PKGBUILD
│       ├── pkgconf/PKGBUILD
│       ├── binutils/PKGBUILD
│       ├── gperf/PKGBUILD
│       ├── libffi/PKGBUILD
│       ├── iana-etc/PKGBUILD
│       ├── psmisc/PKGBUILD
│       ├── less/PKGBUILD
│       ├── libpipeline/PKGBUILD
│       ├── man-pages/PKGBUILD
│       ├── gettext/PKGBUILD
│       ├── gdbm/PKGBUILD
│       ├── groff/PKGBUILD
│       ├── texinfo/PKGBUILD
│       ├── procps-ng/PKGBUILD
│       ├── inetutils/PKGBUILD
│       ├── iproute2/PKGBUILD
│       ├── expat/PKGBUILD
│       ├── pcre2/PKGBUILD
│       ├── libtool/PKGBUILD
│       ├── autoconf/PKGBUILD
│       ├── automake/PKGBUILD
│       ├── elfutils/PKGBUILD
│       ├── linux-api-headers/PKGBUILD
│       ├── tzdata/PKGBUILD
│       ├── shadow/PKGBUILD
│       ├── openssl/PKGBUILD
│       ├── perl/PKGBUILD
│       ├── perl-xml-parser/PKGBUILD
│       ├── intltool/PKGBUILD
│       ├── sqlite/PKGBUILD
│       └── ninja/PKGBUILD
├── scripts/
│   ├── detect_lfs_release.py
│   ├── import_lfs.py
│   ├── prepare_lfs_sources.sh
│   └── build_bootstrap.sh
├── .gitignore
├── LICENSE
└── README.md
```

Generated build products and source caches are written under `output/` and `.cache/` on GitHub-hosted runners and are not committed to the repository. The generated `manifests/lfs-packages.json` file is included in workflow artifacts.

## Automatic LFS release tracking

The bootstrap workflow runs a lightweight scheduled check every day at 03:17 UTC:

1. Detect the newest non-release-candidate `lfs-packages-<version>.tar` bundle.
2. Look for the corresponding verified bundle in the GitHub Actions cache.
3. Exit successfully without rebuilding when that release was already processed.
4. Start the complete bootstrap build when a new stable release is detected.
5. Verify the bundle checksum, recipe versions, and required filenames before compilation.
6. Publish packages only after every safety check and build step succeeds.

A new LFS release is never allowed to silently rewrite recipes. If upstream version changes require recipe work, the automatic run stops before publishing and clearly reports the mismatches.

Manual runs can select `latest` or a specific available stable release. They rebuild by default; the `force_rebuild` input can be disabled to perform the same cache-based check as the scheduler.

## Current bootstrap package set

The workflow builds sixty-six packages inside an Arch Linux container:

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
- `gmp`
- `mpfr`
- `mpc`
- `bison`
- `flex`
- `bc`
- `pkgconf`
- `binutils`
- `gperf`
- `libffi`
- `iana-etc`
- `psmisc`
- `less`
- `libpipeline`
- `man-pages`
- `gettext`
- `gdbm`
- `groff`
- `texinfo`
- `procps-ng`
- `inetutils`
- `iproute2`
- `expat`
- `pcre2`
- `libtool`
- `autoconf`
- `automake`
- `elfutils`
- `linux-api-headers`
- `tzdata`
- `shadow`
- `openssl`
- `perl`
- `perl-xml-parser`
- `intltool`
- `sqlite`
- `ninja`
- `lz4`
- `tcl`
- `expect`
- `dejagnu`
- `kbd`

The workflow creates an `only-core` ALPM repository database and uploads a versioned GitHub Actions artifact.

## Current scope

This repository contains the initial project definition and bootstrap automation. It does not yet provide an installable operating system.
