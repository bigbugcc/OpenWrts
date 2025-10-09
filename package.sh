#!/bin/bash
git clone --depth 1 https://github.com/kenzok8/small-package package/otherapp/small-package
git clone --depth 1 https://github.com/destan19/OpenAppFilter package/otherapp/OpenAppFilter

# Theme
# luci-theme-neobird
git clone --depth 1 https://github.com/thinktip/luci-theme-neobird.git package/otherapp/luci-theme-neobird

# Mentohust
git clone --depth 1 https://github.com/KyleRicardo/MentoHUST-OpenWrt-ipk.git package/otherapp/mentohust

# OpenClash
git clone --depth 1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash