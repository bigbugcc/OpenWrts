#!/bin/bash
# Modify default system settings

# sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
# 替换默认主题
rm -rf package/lean/luci-theme-argon 
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git  package/lean/luci-theme-argon