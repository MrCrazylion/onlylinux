#!/usr/bin/env bash

set -euo pipefail

packages=(
  filesystem
  pkgconf
  binutils
  gperf
  libffi
  gmp
  mpfr
  mpc
  bison
  flex
  bc
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
  iana-etc
  psmisc
  less
  libpipeline
  man-pages
  gettext
  gdbm
  groff
  texinfo
  procps-ng
  inetutils
  iproute2
  expat
  pcre2
  libtool
  autoconf
  automake
  elfutils
  linux-api-headers
  tzdata
  shadow
  openssl
  perl
  perl-xml-parser
  intltool
  sqlite
  ninja
  lz4
  tcl
  expect
  dejagnu
  kbd
  kmod
  util-linux
  e2fsprogs
  glibc
  gcc
  python
  flit-core
  packaging
  wheel
  setuptools
  meson
  grub
  vim
  markupsafe
  jinja2
  systemd
  dbus
  man-db
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
