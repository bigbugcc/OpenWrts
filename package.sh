#!/bin/bash
git clone  https://github.com/bigbugcc/OpenwrtApp package/otherapp/OpenwrtApp
git clone  https://github.com/destan19/OpenAppFilter package/otherapp/OpenAppFilter
git clone  https://github.com/zzsj0928/luci-app-pushbot package/otherapp/luci-app-pushbot

# Theme
# luci-theme-neobird
git clone https://github.com/thinktip/luci-theme-neobird.git package/otherapp/luci-theme-neobird

# Mentohust
git clone https://github.com/KyleRicardo/MentoHUST-OpenWrt-ipk.git package/otherapp/mentohust

# UnblockNeteaseMusic
git clone -b master  https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/unblockneteasemusic