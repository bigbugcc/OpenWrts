#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-lede}"
REPO_BRANCH="${REPO_BRANCH:-master}"
CLONE_DIR="${1:-openwrt}"

echo "======================================"
echo "OpenWrt Source Clone Script"
echo "======================================"
echo "REPO: $REPO"
echo "REPO_BRANCH: $REPO_BRANCH"
echo "CLONE_DIR: $CLONE_DIR"
echo "======================================"

case "$REPO" in
  lede)
    REPO_URL="https://github.com/coolsnowwolf/lede"
    echo "Using Lean's LEDE source"
    ;;
  immortalwrt)
    REPO_URL="https://github.com/immortalwrt/immortalwrt"
    echo "Using ImmortalWrt source"
    ;;
  *)
    echo "Error: Unknown REPO value: $REPO"
    echo "Supported values: lede, immortalwrt"
    exit 1
    ;;
esac

if [ -d "$CLONE_DIR" ]; then
  echo "Error: Directory '$CLONE_DIR' already exists."
  exit 1
fi

git clone --depth 1 "$REPO_URL" -b "$REPO_BRANCH" "$CLONE_DIR"

echo "======================================"
echo "Clone completed successfully"
echo "Source directory: $(pwd)/$CLONE_DIR"
echo "Repository: $REPO ($REPO_URL)"
echo "Branch: $REPO_BRANCH"
echo "======================================"
