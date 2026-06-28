#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="${REPO:-lede}"
OPENWRT_DIR="${OPENWRT_DIR:-${1:-openwrt}}"

if [ -f "$PWD/feeds.conf.default" ]; then
  OPENWRT_DIR="$PWD"
elif [ ! -d "$OPENWRT_DIR" ] && [ -d "$ROOT_DIR/$OPENWRT_DIR" ]; then
  OPENWRT_DIR="$ROOT_DIR/$OPENWRT_DIR"
fi

FEEDS_FILE="$ROOT_DIR/feeds/$REPO.conf"
TARGET_FEEDS="$OPENWRT_DIR/feeds.conf.default"

if [ ! -f "$FEEDS_FILE" ]; then
  echo "Error: repo feeds file not found: $FEEDS_FILE"
  exit 1
fi

if [ ! -f "$TARGET_FEEDS" ]; then
  echo "Error: OpenWrt feeds file not found: $TARGET_FEEDS"
  exit 1
fi

cat "$FEEDS_FILE" >> "$TARGET_FEEDS"
echo "Applied feeds for REPO=$REPO from $FEEDS_FILE"
