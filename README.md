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
2. Import package versions from the stable Linux From Scratch release.
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

Core package versions are selected using the stable Linux From Scratch release as a reference.

### System and desktop

System components, GNOME, and desktop technologies are selected from their stable upstream releases and built against the Only Linux core.

### Additional software

Additional packages are maintained independently and built for Only Linux repositories.

## Build infrastructure

Package builds are intended to run automatically in clean, reproducible environments on hosted infrastructure. Developers should not need to build the distribution directly on their personal computers.

## Repository layout

```text
onlylinux/
├── .github/
│   └── workflows/
│       ├── test-build.yml
│       └── build-bash.yml
├── config/
│   ├── release.yaml
│   └── core-packages.yaml
├── manifests/
│   └── README.md
├── packages/
│   └── core/
│       └── bash/
│           └── PKGBUILD
├── scripts/
│   └── import_lfs.py
├── .gitignore
├── LICENSE
└── README.md
```

Generated build products are written under `output/` on GitHub-hosted runners and are not committed to the repository. The generated `manifests/lfs-packages.json` file is included in workflow artifacts.

## Bootstrap pipeline

The initial pipeline imports stable Linux From Scratch metadata, verifies the selected Bash version, builds the package inside an Arch Linux container, creates an `only-core` ALPM repository database, and uploads the result as a GitHub Actions artifact.

## Current scope

This repository contains the initial project definition and bootstrap automation. It does not yet provide an installable operating system.
