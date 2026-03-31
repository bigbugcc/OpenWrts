#!/bin/bash

REPO="${REPO:-lede}"
echo "Loading packages for REPO: $REPO"

# Common packages (compatible with both lede and immortalwrt)
git clone --depth 1 https://github.com/destan19/OpenAppFilter package/otherapp/OpenAppFilter

# Theme
# luci-theme-neobird
git clone --depth 1 https://github.com/thinktip/luci-theme-neobird.git package/otherapp/luci-theme-neobird

# Mentohust
git clone --depth 1 https://github.com/KyleRicardo/MentoHUST-OpenWrt-ipk.git package/otherapp/mentohust

# OpenClash
git clone --depth 1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

case "$REPO" in
  lede)
    # small-package collection (designed for lede, may conflict with immortalwrt built-in packages)
    git clone --depth 1 https://github.com/kenzok8/small-package package/otherapp/small-package
    ;;
  immortalwrt)
    # immortalwrt has richer built-in packages, skip small-package to avoid conflicts
    echo "Skipping small-package for immortalwrt to avoid package conflicts."
    ;;
  *)
    echo "Error: Unknown REPO value '$REPO'."
    exit 1
    ;;
esac