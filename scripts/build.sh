#!/usr/bin/env bash
set -euo pipefail

OPENWRT_DIR="${OPENWRT_DIR:-openwrt}"

cd "$OPENWRT_DIR"

make download -j"$(nproc)"
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;

echo "$(nproc) thread compile"
make -j"$(nproc)" V=s || make -j4 V=s
