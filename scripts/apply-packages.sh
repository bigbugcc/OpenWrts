#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="${REPO:-lede}"
OPENWRT_DIR="${OPENWRT_DIR:-${1:-openwrt}}"

if [ -d "$PWD/package" ] && [ -d "$PWD/scripts" ]; then
  OPENWRT_DIR="$PWD"
elif [ ! -d "$OPENWRT_DIR" ] && [ -d "$ROOT_DIR/$OPENWRT_DIR" ]; then
  OPENWRT_DIR="$ROOT_DIR/$OPENWRT_DIR"
fi

PACKAGE_SCRIPT="$ROOT_DIR/packages/$REPO.sh"

if [ ! -f "$PACKAGE_SCRIPT" ]; then
  echo "Error: repo package script not found: $PACKAGE_SCRIPT"
  exit 1
fi

cd "$OPENWRT_DIR"
bash "$PACKAGE_SCRIPT"
