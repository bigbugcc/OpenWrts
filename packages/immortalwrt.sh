#!/usr/bin/env bash
set -euo pipefail

clone_package() {
  local repo_url="$1"
  local dest="$2"

  if [ -d "$dest" ]; then
    echo "Package path already exists, skipping: $dest"
    return
  fi

  git clone --depth 1 "$repo_url" "$dest"
}

mkdir -p package/otherapp

clone_package https://github.com/destan19/OpenAppFilter package/otherapp/OpenAppFilter
clone_package https://github.com/thinktip/luci-theme-neobird.git package/otherapp/luci-theme-neobird
clone_package https://github.com/KyleRicardo/MentoHUST-OpenWrt-ipk.git package/otherapp/mentohust
clone_package https://github.com/vernesong/OpenClash.git package/luci-app-openclash

echo "Skipping kenzok8/small-package for immortalwrt to avoid package conflicts."
