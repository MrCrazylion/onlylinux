#!/usr/bin/env bash

set -euo pipefail

packages=(
  filesystem
  zlib
  xz
  zstd
  bash
  coreutils
)

pacman -Syu --noconfirm
pacman -S --needed --noconfirm git sudo namcap

if ! id builder >/dev/null 2>&1; then
  useradd --create-home builder
fi

printf '%s\n' 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
chmod 440 /etc/sudoers.d/builder

for package_name in "${packages[@]}"; do
  package_dir="/workspace/packages/core/${package_name}"

  echo "Building ${package_name}"
  chown -R builder:builder "${package_dir}"

  sudo -u builder bash -euxo pipefail -c "
    cd '${package_dir}'
    makepkg --syncdeps --cleanbuild --noconfirm --needed
  "

  (
    cd "${package_dir}"
    namcap PKGBUILD || true

    for package_file in ./*.pkg.tar.zst; do
      namcap "${package_file}" || true
    done
  )
done
