#!/usr/bin/env bash

set -euo pipefail

packages=(
  filesystem
  attr
  acl
  libcap
  libxcrypt
  zlib
  xz
  zstd
  bzip2
  ncurses
  readline
  bash
  m4
  file
  diffutils
  coreutils
  sed
  grep
  gawk
  findutils
  gzip
  make
  patch
  tar
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
  chown -R builder:builder "${package_dir}"

  echo "Verifying sources for ${package_name}"
  sudo -u builder bash -euxo pipefail -c "
    cd '${package_dir}'
    makepkg --verifysource --noconfirm
  "
done

for package_name in "${packages[@]}"; do
  package_dir="/workspace/packages/core/${package_name}"
  check_flag=""

  # The complete M4 and Gawk suites are kept for dedicated validation jobs.
  # Gawk PMA tests are not stable inside the hosted container.
  if [[ "${package_name}" == "m4" || "${package_name}" == "gawk" ]]; then
    check_flag="--nocheck"
  fi

  echo "Building ${package_name}"
  sudo -u builder bash -euxo pipefail -c "
    cd '${package_dir}'
    makepkg --syncdeps --cleanbuild --noconfirm --needed ${check_flag}
  "

  if [[ "${package_name}" == "gawk" ]]; then
    test "$(${package_dir}/src/gawk-${pkgver:-5.3.2}/gawk 'BEGIN { print 6 * 7 }')" = "42"
  fi

  (
    cd "${package_dir}"
    namcap PKGBUILD || true

    for package_file in ./*.pkg.tar.zst; do
      namcap "${package_file}" || true
    done
  )
done
#!/usr/bin/env bash

set -euo pipefail

packages=(
  filesystem
  zlib
  xz
  zstd
  bzip2
  ncurses
  readline
  bash
  m4
  file
  diffutils
  coreutils
  sed
  grep
  gawk
  findutils
  gzip
  make
  patch
  tar
  attr
  acl
  libcap
  libxcrypt
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
  chown -R builder:builder "${package_dir}"

  echo "Verifying sources for ${package_name}"
  sudo -u builder bash -euxo pipefail -c "
    cd '${package_dir}'
    makepkg --verifysource --noconfirm
  "
done

for package_name in "${packages[@]}"; do
  package_dir="/workspace/packages/core/${package_name}"
  check_flag=""

  # The complete M4 and Gawk suites are kept for dedicated validation jobs.
  # Gawk PMA tests are not stable inside the hosted container.
  if [[ "${package_name}" == "m4" || "${package_name}" == "gawk" ]]; then
    check_flag="--nocheck"
  fi

  echo "Building ${package_name}"
  sudo -u builder bash -euxo pipefail -c "
    cd '${package_dir}'
    makepkg --syncdeps --cleanbuild --noconfirm --needed ${check_flag}
  "

  if [[ "${package_name}" == "gawk" ]]; then
    test "$(${package_dir}/src/gawk-${pkgver:-5.3.2}/gawk 'BEGIN { print 6 * 7 }')" = "42"
  fi

  (
    cd "${package_dir}"
    namcap PKGBUILD || true

    for package_file in ./*.pkg.tar.zst; do
      namcap "${package_file}" || true
    done
  )
done
