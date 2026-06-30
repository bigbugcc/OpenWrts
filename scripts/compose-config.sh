#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENWRT_DIR="${OPENWRT_DIR:-openwrt}"
TARGET_CONFIG="${TARGET_CONFIG:-}"
APP_CONFIG="${APP_CONFIG:-}"
DRIVER_CONFIG="${DRIVER_CONFIG:-}"

resolve_path() {
  local path="$1"

  if [ -z "$path" ]; then
    return
  fi

  if [ -f "$path" ]; then
    printf '%s\n' "$path"
    return
  fi

  if [ -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "$ROOT_DIR/$path"
    return
  fi

  echo "Error: config file not found: $path" >&2
  exit 1
}

if [ ! -d "$OPENWRT_DIR" ] && [ -d "$ROOT_DIR/$OPENWRT_DIR" ]; then
  OPENWRT_DIR="$ROOT_DIR/$OPENWRT_DIR"
fi

if [ -z "$TARGET_CONFIG" ] || [ -z "$APP_CONFIG" ]; then
  echo "Error: TARGET_CONFIG and APP_CONFIG are required."
  exit 1
fi

TARGET_CONFIG_PATH="$(resolve_path "$TARGET_CONFIG")"
APP_CONFIG_PATH="$(resolve_path "$APP_CONFIG")"
DRIVER_CONFIG_PATH="$(resolve_path "$DRIVER_CONFIG")"

if [ -d "$ROOT_DIR/files" ]; then
  mkdir -p "$OPENWRT_DIR/files"
  cp -R "$ROOT_DIR/files/." "$OPENWRT_DIR/files/"
fi

: > "$OPENWRT_DIR/.config"
cat "$TARGET_CONFIG_PATH" >> "$OPENWRT_DIR/.config"
printf '\n' >> "$OPENWRT_DIR/.config"

if [ -n "$DRIVER_CONFIG_PATH" ]; then
  cat "$DRIVER_CONFIG_PATH" >> "$OPENWRT_DIR/.config"
  printf '\n' >> "$OPENWRT_DIR/.config"
fi

cat "$APP_CONFIG_PATH" >> "$OPENWRT_DIR/.config"

cd "$OPENWRT_DIR"
make defconfig

awk '
  /^CONFIG_DEFAULT_luci[^=]*=/ {
    sub(/=.*/, "", $0)
    print "# " $0 " is not set"
    next
  }
  { print }
' .config > .config.tmp
mv .config.tmp .config

make defconfig
cat .config
