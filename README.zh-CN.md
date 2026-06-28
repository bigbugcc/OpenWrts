# OpenWrts

[English](./README.md) | [简体中文](./README.zh-CN.md)

OpenWrts 是一个基于 GitHub Actions 的 OpenWrt 云编译仓库。默认 README 为英文版，当前页面为中文说明。

<p align="center">
  <img src="./assets/images/action1.jpg" alt="OpenWrts" width="500" />
</p>

![Weekly Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/weekly-release.yml/badge.svg)
![Manual Build](https://github.com/bigbugcc/OpenWrts/actions/workflows/manual-build.yml/badge.svg)
![Release Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square)
![Latest Release](https://img.shields.io/github/v/release/bigbugcc/OpenWrts?style=flat-square)
![License](https://img.shields.io/github/license/bigbugcc/OpenWrts?style=flat-square)

## 固件构建列表

固件构建列表统一维护在 [`manifests/builds.json`](./manifests/builds.json)。定时 workflow 每周运行一次，`auto` 模式会按 ISO 周奇偶在 LEDE 和 ImmortalWrt 之间轮换。

| 源码 | 设备 ID | 平台 | 风格 | Workflow 状态 | 下载统计 |
| --- | --- | --- | --- | --- | --- |
| `lede` | `x86_64` | x86_64 generic | `standard` | ![Weekly Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/weekly-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |
| `lede` | `rpi3` | Raspberry Pi 3B/3B+ | `standard` | ![Weekly Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/weekly-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |
| `lede` | `rpi4` | Raspberry Pi 4B | `standard` | ![Weekly Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/weekly-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |
| `lede` | `rpi5` | Raspberry Pi 5 | `standard` | ![Weekly Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/weekly-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |
| `lede` | `rockchip` | R68S、NanoPi R2S/R4S/R5C/R5S、Orange Pi R1 Plus | `standard` | ![Weekly Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/weekly-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |
| `immortalwrt` | `x86_64-lite` | x86_64 generic | `lite` | ![Weekly Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/weekly-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |

## LuCI 插件列表

### LEDE Standard

| 分类 | 插件 |
| --- | --- |
| 商店与代理 | `luci-app-store`, `luci-app-openclash`, `luci-app-passwall2`, `luci-app-ssr-plus` |
| 网络 | `luci-app-ddns`, `luci-app-mwan3`, `luci-app-n2n`, `luci-app-openvpn`, `luci-app-softethervpn`, `luci-app-syncdial`, `luci-app-upnp`, `luci-app-wireguard`, `luci-app-zerotier`, `luci-app-smartdns` |
| 服务 | `luci-app-adguardhome`, `luci-app-docker`, `luci-app-dockerman`, `luci-app-filebrowser`, `luci-app-frpc`, `luci-app-nfs`, `luci-app-nps`, `luci-app-samba4`, `luci-app-ttyd`, `luci-app-vsftpd` |
| 系统与工具 | `luci-app-accesscontrol`, `luci-app-arpbind`, `luci-app-autoreboot`, `luci-app-cifs-mount`, `luci-app-commands`, `luci-app-control-timewol`, `luci-app-diskman`, `luci-app-filetransfer`, `luci-app-firewall`, `luci-app-netdata`, `luci-app-nlbwmon`, `luci-app-onliner`, `luci-app-pushbot`, `luci-app-qos`, `luci-app-serverchan`, `luci-app-usb-printer`, `luci-app-vlmcsd`, `luci-app-wol` |
| 扩展应用 | `luci-app-ipsec-vpnd`, `luci-app-mentohust`, `luci-app-oaf`, `luci-app-qbittorrent_static`, `luci-app-qbittorrent-simple_dynamic`, `luci-app-turboacc` |
| 主题 | `luci-theme-argon`, `luci-theme-bootstrap`, `luci-theme-infinityfreedom`, `luci-theme-material`, `luci-theme-netgear`, `luci-theme-neobird` |

### ImmortalWrt Lite

| 分类 | 插件 |
| --- | --- |
| 商店与代理 | `luci-app-store`, `luci-app-openclash`, `luci-app-passwall2`, `luci-app-ssr-plus` |
| 网络 | `luci-app-accesscontrol`, `luci-app-smartdns`, `luci-app-turboacc`, `luci-proto-wireguard` |
| 服务 | `luci-app-docker`, `luci-app-dockerman`, `luci-app-filetransfer`, `luci-app-firewall`, `luci-app-netdata`, `luci-app-oaf`, `luci-app-onliner`, `luci-app-ttyd` |
| 系统默认 | `default-settings`, `default-settings-chn`, `luci-app-autoreboot` |
| 主题 | `luci-theme-argon`, `luci-theme-bootstrap`, `luci-theme-material` |

## 支持的源码

| 源码标识 | 上游仓库 | 默认分支 | 说明 |
| --- | --- | --- | --- |
| `lede` | <https://github.com/coolsnowwolf/lede> | `master` | Lean LEDE，当前用于 standard 构建 |
| `immortalwrt` | <https://github.com/immortalwrt/immortalwrt> | `master` | ImmortalWrt，当前用于 x86_64 lite 构建 |

两套源码的 SDK、feeds、LuCI 版本、软件包集合和插件兼容性并不完全一致，因此应用配置和插件脚本按源码隔离维护。

## 工作流

| Workflow | 用途 |
| --- | --- |
| [`weekly-release.yml`](./.github/workflows/weekly-release.yml) | 每周定时发布。`auto` 模式会按 ISO 周奇偶在 LEDE 和 ImmortalWrt 之间轮换 |
| [`manual-build.yml`](./.github/workflows/manual-build.yml) | 手动构建入口，可选择源码、设备、风格、分支和是否发布 |
| [`build-openwrt.yml`](./.github/workflows/build-openwrt.yml) | reusable workflow，负责构建单个 matrix 项 |
| [`ActionTrigger.yml`](./.github/workflows/ActionTrigger.yml) | 手动维护 workflow，用于清理旧 workflow runs 和旧 releases |

定时 workflow 使用 UTC 时间：

```yaml
schedule:
  - cron: "23 16 * * 6"
```

约等于 Asia/Shanghai 时区的周日 00:23。

## 构建流程

```text
weekly/manual workflow
  -> scripts/resolve-matrix.py 生成构建矩阵
  -> build-openwrt.yml
     -> scripts/prepare-env.sh
     -> scripts/clone-source.sh
     -> scripts/apply-system.sh
     -> scripts/apply-feeds.sh
     -> scripts/apply-packages.sh
     -> scripts/compose-config.sh
     -> scripts/build.sh
     -> 上传 artifact / release
```

## 仓库结构

```text
.github/workflows/
  build-openwrt.yml      reusable 构建 workflow
  weekly-release.yml     定时源码轮换发布 workflow
  manual-build.yml       手动构建 workflow
  ActionTrigger.yml      手动维护 workflow

manifests/
  builds.json            构建矩阵定义

feeds/
  lede.conf              LEDE feeds
  immortalwrt.conf       ImmortalWrt feeds

packages/
  lede.sh                LEDE 第三方插件
  immortalwrt.sh         ImmortalWrt 第三方插件

configs/
  targets/               按源码隔离的 target/device 配置
  apps/                  按源码隔离的 LuCI 应用配置
  drivers/               按源码隔离的驱动扩展配置

scripts/
  prepare-env.sh         安装编译依赖
  clone-source.sh        拉取选定的上游源码
  apply-system.sh        应用默认系统设置
  apply-feeds.sh         追加按源码隔离的 feeds
  apply-packages.sh      拉取按源码隔离的第三方插件
  compose-config.sh      合成 .config 并执行 make defconfig
  build.sh               下载依赖并编译固件
  resolve-matrix.py      解析 manifests/builds.json
```

根目录下的 `source.sh`、`environment.sh`、`configure.sh` 和 `package.sh` 是兼容包装入口，内部会转发到 `scripts/` 下的新脚本。

## 缓存策略

新 workflow 使用 `actions/cache` 缓存 `dl` 和 `.ccache`。cache key 包含：

```text
repo + branch + cache_scope + hash(feeds/packages/scripts/configs/manifests)
```

这样可以避免 LEDE、ImmortalWrt、不同设备和不同固件风格之间混用不兼容缓存。

## 固件默认设置

- 管理地址：`192.168.10.1`
- 用户：`root`
- 密码：`password`

## 手动构建

进入 GitHub Actions，运行 `Manual OpenWrt Build`，然后选择：

- `repo`: `lede` 或 `immortalwrt`
- `device`: `all` 或构建矩阵里的设备 ID
- `flavor`: `all`、`standard` 或 `lite`
- `branch`: 留空使用 manifest 默认分支，也可以填写上游分支
- `upload_release`: 是否上传固件到 GitHub Releases

## 本地矩阵检查

```powershell
python scripts\resolve-matrix.py --repo lede --device x86_64
python scripts\resolve-matrix.py --repo immortalwrt --device all
python scripts\resolve-matrix.py --repo auto
```

如果 Python 不在 `PATH` 中，可以使用 Python 可执行文件的完整路径运行脚本。

## 添加新设备

1. 在 `configs/targets/<repo>/` 下添加 target/device 配置。
2. 在 `configs/apps/<repo>/` 下添加或复用应用配置。
3. 如有需要，在 `configs/drivers/<repo>/` 下添加驱动扩展。
4. 在 `manifests/builds.json` 中添加设备项。
5. 如果设备需要额外插件，更新 `packages/<repo>.sh`。

## 截图

![OpenWrt](./assets/images/openwrt.png)

![App Store](./assets/images/appstore.png)

![Service](./assets/images/service.png)

![Network](./assets/images/network.png)

## 致谢

- <https://github.com/P3TERX/Actions-OpenWrt>
- <https://github.com/coolsnowwolf/lede>
- <https://github.com/immortalwrt/immortalwrt>
- <https://github.com/jerrykuku/luci-theme-argon>
- <https://github.com/linkease/istore>

## License

本项目基于 MIT License 发布。详见 [`LICENSE`](./LICENSE)。
