#!/bin/bash
# Modify default system settings

# sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default