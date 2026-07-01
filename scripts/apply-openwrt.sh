#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="${REPO:-lede}"
OPENWRT_DIR="${OPENWRT_DIR:-openwrt}"

usage() {
  cat <<'USAGE'
Usage: scripts/apply-openwrt.sh [--openwrt-dir path] [system|feeds|packages|all]...

Modes:
  system    Apply default OpenWrt system settings.
  feeds     Append shared feeds and source-specific feeds.
  packages  Clone source-specific third-party packages.
  all       Run system, feeds, and packages in that order.
USAGE
}

resolve_openwrt_dir() {
  if [ -d "$PWD/package/base-files" ] || { [ -d "$PWD/package" ] && [ -d "$PWD/scripts" ]; }; then
    printf '%s\n' "$PWD"
    return
  fi

  if [ -d "$OPENWRT_DIR" ]; then
    printf '%s\n' "$OPENWRT_DIR"
    return
  fi

  if [ -d "$ROOT_DIR/$OPENWRT_DIR" ]; then
    printf '%s\n' "$ROOT_DIR/$OPENWRT_DIR"
    return
  fi

  printf '%s\n' "$OPENWRT_DIR"
}

apply_system() {
  local openwrt_dir="$1"
  local config_generate="$openwrt_dir/package/base-files/files/bin/config_generate"

  if [ ! -f "$config_generate" ]; then
    echo "Error: OpenWrt config_generate not found: $config_generate" >&2
    exit 1
  fi

  sed -i 's/192.168.1.1/192.168.10.1/g' "$config_generate"
  echo "Default LAN IP changed to 192.168.10.1"
}

apply_feeds() {
  local openwrt_dir="$1"
  local common_feeds_file="$ROOT_DIR/feeds/common.conf"
  local feeds_file="$ROOT_DIR/feeds/$REPO.conf"
  local target_feeds="$openwrt_dir/feeds.conf.default"
  local applied=0

  if [ ! -f "$target_feeds" ]; then
    echo "Error: OpenWrt feeds file not found: $target_feeds" >&2
    exit 1
  fi

  if [ -f "$common_feeds_file" ]; then
    cat "$common_feeds_file" >> "$target_feeds"
    echo "Applied shared feeds from $common_feeds_file"
    applied=1
  fi

  if [ -f "$feeds_file" ]; then
    cat "$feeds_file" >> "$target_feeds"
    echo "Applied feeds for REPO=$REPO from $feeds_file"
    applied=1
  fi

  if [ "$applied" -eq 0 ]; then
    echo "Error: no shared or repo feeds found for REPO=$REPO" >&2
    exit 1
  fi
}

apply_packages() {
  local openwrt_dir="$1"
  local package_script="$ROOT_DIR/packages/$REPO.sh"

  if [ ! -f "$package_script" ]; then
    echo "Error: repo package script not found for REPO=$REPO: $package_script" >&2
    exit 1
  fi

  (cd "$openwrt_dir" && bash "$package_script")
}

MODES=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --openwrt-dir)
      if [ "$#" -lt 2 ]; then
        echo "Error: --openwrt-dir requires a path." >&2
        exit 2
      fi
      OPENWRT_DIR="$2"
      shift 2
      ;;
    --openwrt-dir=*)
      OPENWRT_DIR="${1#*=}"
      shift
      ;;
    *)
      MODES+=("$1")
      shift
      ;;
  esac
done

if [ "${#MODES[@]}" -eq 0 ]; then
  usage
  exit 2
fi

OPENWRT_DIR="$(resolve_openwrt_dir)"

for mode in "${MODES[@]}"; do
  case "$mode" in
    system)
      apply_system "$OPENWRT_DIR"
      ;;
    feeds)
      apply_feeds "$OPENWRT_DIR"
      ;;
    packages)
      apply_packages "$OPENWRT_DIR"
      ;;
    all)
      apply_system "$OPENWRT_DIR"
      apply_feeds "$OPENWRT_DIR"
      apply_packages "$OPENWRT_DIR"
      ;;
    *)
      echo "Unknown apply mode: $mode" >&2
      usage >&2
      exit 2
      ;;
  esac
done
