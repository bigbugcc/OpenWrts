#!/bin/bash
# Modify default system settings

# 修改默认IP为192.168.10.1
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate 

# 自定义smpackage
echo 'src-git smpackage  https://github.com/kenzok8/small-package' >>feeds.conf.default

# 替换默认主题
rm -rf package/lean/luci-theme-argon 
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git  package/lean/luci-theme-argon
