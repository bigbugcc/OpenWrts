#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-lede}"
REPO_BRANCH="${REPO_BRANCH:-master}"
CLONE_DIR="${1:-openwrt}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "======================================"
echo "OpenWrt Source Clone Script"
echo "======================================"
echo "REPO: $REPO"
echo "REPO_BRANCH: $REPO_BRANCH"
echo "CLONE_DIR: $CLONE_DIR"
echo "======================================"

REPO_URL="$(node "$ROOT_DIR/scripts/openwrts.mjs" repo-url --repo "$REPO")"
echo "Using $REPO source: $REPO_URL"

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
