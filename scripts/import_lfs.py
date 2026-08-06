#!/usr/bin/env python3

from __future__ import annotations

import json
import re
import sys
import urllib.request
from pathlib import Path
from urllib.parse import urlparse


LFS_RELEASE = "13.0"
LFS_DOWNLOADS = (
    f"https://www.linuxfromscratch.org/lfs/downloads/{LFS_RELEASE}"
)
OUTPUT_PATH = Path("manifests/lfs-packages.json")
ARCHIVE_SUFFIXES = (
    ".tar.xz",
    ".tar.gz",
    ".tar.bz2",
    ".tar.zst",
    ".tgz",
)


def download_text(url: str) -> str:
    request = urllib.request.Request(
        url,
        headers={"User-Agent": "Only-Linux-LFS-Importer/0.1"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def strip_archive_suffix(filename: str) -> str | None:
    for suffix in ARCHIVE_SUFFIXES:
        if filename.endswith(suffix):
            return filename[: -len(suffix)]
    return None


def split_name_and_version(filename: str) -> tuple[str, str] | None:
    base_name = strip_archive_suffix(filename)
    if base_name is None:
        return None

    match = re.match(
        r"^(?P<name>.+?)-(?P<version>[0-9][A-Za-z0-9._+-]*)$",
        base_name,
    )
    if match is None:
        return None

    return match.group("name"), match.group("version")


def parse_checksums(contents: str) -> dict[str, str]:
    checksums: dict[str, str] = {}

    for line in contents.splitlines():
        parts = line.split()
        if len(parts) < 2:
            continue

        checksum = parts[0]
        filename = parts[-1].lstrip("*")
        checksums[filename] = checksum

    return checksums


def main() -> int:
    try:
        wget_list = download_text(f"{LFS_DOWNLOADS}/wget-list")
        md5sums = download_text(f"{LFS_DOWNLOADS}/md5sums")
    except Exception as error:
        print(f"Failed to download LFS metadata: {error}", file=sys.stderr)
        return 1

    checksums = parse_checksums(md5sums)
    packages: list[dict[str, str | None]] = []

    for line in wget_list.splitlines():
        url = line.strip()
        if not url or url.startswith("#"):
            continue

        filename = Path(urlparse(url).path).name
        parsed = split_name_and_version(filename)
        if parsed is None:
            continue

        source_name, version = parsed
        packages.append(
            {
                "source_name": source_name,
                "version": version,
                "filename": filename,
                "url": url,
                "md5": checksums.get(filename),
            }
        )

    packages.sort(
        key=lambda package: (
            str(package["source_name"]),
            str(package["filename"]),
        )
    )

    if not any(package["source_name"] == "bash" for package in packages):
        print("The LFS metadata did not contain Bash", file=sys.stderr)
        return 1

    output = {
        "release": LFS_RELEASE,
        "metadata_source": LFS_DOWNLOADS,
        "package_count": len(packages),
        "packages": packages,
    }

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(
        json.dumps(output, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )

    print(f"Wrote {len(packages)} LFS package records to {OUTPUT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
