## 🔍 树莓派4B USB引导 & WiFi 问题分析

结合该 issue 以及各位反馈的情况，这里做一个综合分析，供大家排查参考：

---

### 📋 问题总结

根据评论区反馈，问题表现为：
1. **最新几个固件 USB/SD卡 均无法正常启动**（不仅限于USB引导）
2. 部分版本能启动但**无WiFi信号输出**
3. 后台管理地址从 `192.168.10.1` 变更为 `192.168.1.1`
4. 树莓派5 的 AP 也出现 `up: false` 的情况

---

### 🔧 根因分析

#### 1. 固件本身的启动问题
从 @Chickenbi24 的测试来看，即使使用SD卡不做任何修改也启动不了，说明**问题出在固件编译层面**而非 USB 引导配置。上游源码 (`coolsnowwolf/lede`) 的内核/驱动更新可能引入了不兼容的变更。

#### 2. WiFi 驱动问题 (`kmod-brcmfmac`)
- 树莓派4B 的板载 WiFi 芯片 (BCM43455) 依赖 `kmod-brcmfmac` 驱动
- 上游内核版本更新后，WiFi 驱动可能存在兼容性问题或编译配置缺失
- 树莓派5 的 WiFi 问题 (`AP up: false`) 同样指向驱动层面的问题

#### 3. 默认网络配置变更
后台地址从 `192.168.10.1` 变为 `192.168.1.1`，说明固件的默认网络配置 (`/etc/config/network`) 有变动。

---

### 🛠️ 临时排查/解决方案（供用户参考）

**如果系统能通过有线启动：**

```shell
# 1. 检查 WiFi 驱动是否加载
lsmod | grep brcmfmac

# 2. 检查无线设备是否被识别
iw dev
iwinfo

# 3. 重新生成无线配置
wifi detect > /etc/config/wireless
wifi up

# 4. 检查相关包是否安装
opkg list-installed | grep -E "brcmfmac|wpad|hostapd"
```

**USB 引导优化 (`cmdline.txt`)：**
```
console=serial0,115200 console=tty1 root=PARTUUID=029f3cd2-02 rootfstype=squashfs,ext4 rootwait rootdelay=5
```
> 建议使用 `PARTUUID` 而非 `/dev/sda2`，并添加 `rootdelay=5` 确保 USB 设备有足够时间初始化。

---

### ✅ 最新进展

WiFi 问题已尝试修复，请大家关注最新的 Release 版本进行测试，如仍有问题请在此反馈具体表现和启动日志。