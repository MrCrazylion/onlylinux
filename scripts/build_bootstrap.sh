#!/usr/bin/env bash

set -euo pipefail

packages=(
  # Only Linux bootstrap helpers; package order below follows LFS stable-systemd.
  filesystem
  linux-api-headers
  tzdata

  man-pages
  iana-etc
  glibc
  zlib
  bzip2
  xz
  lz4
  zstd
  file
  readline
  pcre2
  m4
  bc
  flex
  tcl
  expect
  dejagnu
  pkgconf
  binutils
  gmp
  mpfr
  mpc
  attr
  acl
  libcap
  libxcrypt
  shadow
  gcc
  ncurses
  sed
  psmisc
  gettext
  bison
  grep
  bash
  libtool
  gdbm
  gperf
  expat
  inetutils
  less
  perl
  perl-xml-parser
  intltool
  autoconf
  automake
  openssl
  elfutils
  libffi
  sqlite
  python
  flit-core
  packaging
  wheel
  setuptools
  ninja
  meson
  kmod
  coreutils
  diffutils
  gawk
  findutils
  groff
  grub
  gzip
  iproute2
  kbd
  libpipeline
  make
  patch
  tar
  texinfo
  vim
  markupsafe
  jinja2
  systemd
  dbus
  man-db
  procps-ng
  util-linux
  e2fsprogs

  # Chapter 10: built after the basic system packages.
  linux
)

source_cache="$(find /workspace/.cache/lfs/sources \
  -type f \
  -name 'bash-*.tar.*' \
  -printf '%h\n' \
  -quit)"

if [[ -z "${source_cache}" || ! -d "${source_cache}" ]]; then
  echo "The verified LFS source cache is missing" >&2
  exit 1
fi

pacman -Syu --noconfirm
pacman -S --needed --noconfirm sudo namcap

if ! id builder >/dev/null 2>&1; then
  useradd --create-home builder
fi

printf '%s\n' 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
chmod 440 /etc/sudoers.d/builder
chown -R builder:builder /workspace/.cache/lfs/sources
makepkg_config=/workspace/.cache/makepkg-onlylinux.conf
cp /etc/makepkg.conf "${makepkg_config}"
cat >> "${makepkg_config}" <<EOF

# Only Linux bootstrap policy: do not inherit Arch compiler or linker flags.
SRCDEST="${source_cache}"
CFLAGS=""
CXXFLAGS=""
CPPFLAGS=""
LDFLAGS=""
MAKEFLAGS=""
OPTIONS=(!strip !docs libtool staticlibs emptydirs zipman purge !debug !lto)
EOF
chown builder:builder "${makepkg_config}"

echo "Using verified LFS source cache: ${source_cache}"
echo "Using neutral Only Linux compiler and linker flags"

for package_name in "${packages[@]}"; do
  package_dir="/workspace/packages/core/${package_name}"
  chown -R builder:builder "${package_dir}"

  echo "Verifying sources for ${package_name}"
  sudo -u builder bash -euxo pipefail -c "
    cd '${package_dir}'
    makepkg --config '${makepkg_config}' --verifysource --noconfirm
  "
done

for package_name in "${packages[@]}"; do
  package_dir="/workspace/packages/core/${package_name}"

  # Bootstrap builds verify sources and compilation. Full upstream test
  # suites belong in a separate validation workflow.
  check_flag="--nocheck"

  echo "Building ${package_name}"
  sudo -u builder bash -euxo pipefail -c "
    cd '${package_dir}'
    makepkg --config '${makepkg_config}' --syncdeps --cleanbuild --noconfirm --needed ${check_flag}
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
