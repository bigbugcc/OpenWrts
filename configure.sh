#!/bin/bash
# Modify default system settings

# 修改默认IP为192.168.10.1
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# luci-theme-infinityfreedom
echo 'src-git infinityfreedom https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom.git' >>feeds.conf.default

# 自定义smpackage
echo 'src-git smpackage  https://github.com/kenzok8/small-package' >>feeds.conf.default


