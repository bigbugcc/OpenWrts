#!/bin/bash
# Clone OpenWrt source code based on REPO environment variable
# Usage: ./yum.sh

set -e

# Get parameters from environment variables
REPO=${REPO:-lede}
REPO_BRANCH=${REPO_BRANCH:-master}
CLONE_DIR=${1:-openwrt}

echo "======================================"
echo "OpenWrt Source Clone Script"
echo "======================================"
echo "REPO: $REPO"
echo "REPO_BRANCH: $REPO_BRANCH"
echo "CLONE_DIR: $CLONE_DIR"
echo "======================================"

# Determine the repository URL based on REPO variable
if [ "$REPO" = "lede" ]; then
    REPO_URL="https://github.com/coolsnowwolf/lede"
    echo "✓ Using Lean's LEDE source"
elif [ "$REPO" = "immortalwrt" ]; then
    REPO_URL="https://github.com/immortalwrt/immortalwrt"
    echo "✓ Using ImmortalWrt source"
else
    echo "✗ Error: Unknown REPO value: $REPO"
    echo "  Supported values: lede, immortalwrt"
    exit 1
fi

echo "Repository URL: $REPO_URL"
echo "Branch: $REPO_BRANCH"
echo ""

# Check if target directory already exists
if [ -d "$CLONE_DIR" ]; then
    echo "✗ Warning: Directory '$CLONE_DIR' already exists!"
    echo "  Please remove it first or use a different directory."
    exit 1
fi

# Clone the repository
echo "Cloning from: $REPO_URL"
echo "This may take a few minutes..."
echo ""

git clone --depth 1 "$REPO_URL" -b "$REPO_BRANCH" "$CLONE_DIR"

if [ $? -eq 0 ]; then
    echo ""
    echo "======================================"
    echo "✓ Clone completed successfully!"
    echo "======================================"
    echo "Source directory: $(pwd)/$CLONE_DIR"
    echo "Repository: $REPO ($REPO_URL)"
    echo "Branch: $REPO_BRANCH"
    echo "======================================"
else
    echo ""
    echo "======================================"
    echo "✗ Clone failed!"
    echo "======================================"
    exit 1
fi
