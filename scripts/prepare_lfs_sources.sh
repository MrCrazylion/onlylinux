#!/usr/bin/env bash

set -euo pipefail

lfs_release="${LFS_RELEASE:?LFS_RELEASE must be set}"
bundle_name="lfs-packages-${lfs_release}.tar"
bundle_base_url="${LFS_BUNDLE_BASE_URL:-https://ftp.lfs-matrix.net/pub/lfs/lfs-packages}"
workspace="${GITHUB_WORKSPACE:-$(pwd)}"
cache_dir="${workspace}/.cache/lfs"
archive="${cache_dir}/${bundle_name}"
checksums="${cache_dir}/MD5SUMS"
sources_dir="${cache_dir}/sources"

download_if_missing() {
  local url="$1"
  local target="$2"

  if [[ -s "${target}" ]]; then
    echo "Using cached $(basename "${target}")"
    return
  fi

  rm -f "${target}.part"
  curl \
    --fail \
    --location \
    --retry 4 \
    --retry-all-errors \
    --connect-timeout 30 \
    --output "${target}.part" \
    "${url}"
  mv "${target}.part" "${target}"
}

mkdir -p "${cache_dir}"

download_if_missing \
  "${bundle_base_url}/${bundle_name}" \
  "${archive}"
download_if_missing \
  "${bundle_base_url}/MD5SUMS" \
  "${checksums}"

expected_md5="$(awk -v bundle="${bundle_name}" \
  '$2 == bundle || $2 == "*" bundle { print $1; exit }' \
  "${checksums}")"

if [[ -z "${expected_md5}" ]]; then
  echo "No checksum found for ${bundle_name}" >&2
  exit 1
fi

actual_md5="$(md5sum "${archive}" | awk '{ print $1 }')"
if [[ "${actual_md5}" != "${expected_md5}" ]]; then
  echo "Checksum mismatch for ${bundle_name}" >&2
  rm -f "${archive}"
  exit 1
fi

rm -rf "${sources_dir}"
mkdir -p "${sources_dir}"
tar -xf "${archive}" -C "${sources_dir}"

if ! find "${sources_dir}" -type f -name 'bash-*.tar.*' -print -quit | grep -q .; then
  echo "The extracted bundle does not contain the expected LFS sources" >&2
  exit 1
fi

echo "Prepared verified LFS ${lfs_release} sources in ${sources_dir}"
