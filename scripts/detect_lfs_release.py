#!/usr/bin/env python3

from __future__ import annotations

import os
import re
import sys
import urllib.request


INDEX_URL = os.environ.get(
    "LFS_BUNDLE_INDEX",
    "https://ftp.lfs-matrix.net/pub/lfs/lfs-packages/",
)
REQUESTED_RELEASE = os.environ.get("REQUESTED_RELEASE", "latest").strip()


def version_key(version: str) -> tuple[int, ...]:
    return tuple(int(part) for part in version.split("."))


def main() -> int:
    request = urllib.request.Request(
        INDEX_URL,
        headers={"User-Agent": "Only-Linux-LFS-Detector/0.1"},
    )

    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            index = response.read().decode("utf-8")
    except Exception as error:
        print(f"Failed to read the LFS bundle index: {error}", file=sys.stderr)
        return 1

    releases = sorted(
        set(
            re.findall(
                r'href=["\x27]lfs-packages-(\d+(?:\.\d+)*)\.tar["\x27]',
                index,
            )
        ),
        key=version_key,
    )

    if not releases:
        print("No stable LFS source bundles were found", file=sys.stderr)
        return 1

    if REQUESTED_RELEASE in ("", "latest"):
        selected = releases[-1]
    else:
        if not re.fullmatch(r"\d+(?:\.\d+)*", REQUESTED_RELEASE):
            print(
                f"Invalid requested LFS release: {REQUESTED_RELEASE}",
                file=sys.stderr,
            )
            return 1
        if REQUESTED_RELEASE not in releases:
            print(
                f"LFS bundle {REQUESTED_RELEASE} is not available",
                file=sys.stderr,
            )
            return 1
        selected = REQUESTED_RELEASE

    print(selected)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
