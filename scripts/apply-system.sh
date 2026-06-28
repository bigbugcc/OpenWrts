#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENWRT_DIR="${OPENWRT_DIR:-${1:-openwrt}}"

if [ -d "$PWD/package/base-files" ]; then
  OPENWRT_DIR="$PWD"
elif [ ! -d "$OPENWRT_DIR" ] && [ -d "$ROOT_DIR/$OPENWRT_DIR" ]; then
  OPENWRT_DIR="$ROOT_DIR/$OPENWRT_DIR"
fi

CONFIG_GENERATE="$OPENWRT_DIR/package/base-files/files/bin/config_generate"

if [ ! -f "$CONFIG_GENERATE" ]; then
  echo "Error: OpenWrt config_generate not found: $CONFIG_GENERATE"
  exit 1
fi

sed -i 's/192.168.1.1/192.168.10.1/g' "$CONFIG_GENERATE"
echo "Default LAN IP changed to 192.168.10.1"
