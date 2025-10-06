# Action Openwrt 云自动编译
⏰ **每周自动拉取最新源码自动编译**

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<br />

<p align="center">
  <a href="https://github.com/bigbugcc/OpenWrts">
    <img src="./assets/images/action1.jpg" alt="Logo" width="500" />
  </a>
  <h3 align="center">Openwrt/LEDE 云编译(带应用商店)</h3>
  <p align="center">
    👉 每周定时自动拉取Openwrt最新源码编译，自动发布到 [<a herf="https://github.com/bigbugcc/OpenWrts/releases"> Releases </a>]👈
    <br />
    <a href="https://github.com/bigbugcc/OpenWrts"><strong>探索本项目的文档 »</strong></a>
    <br />
    <br />
    <a href="https://github.com/bigbugcc/OpenWrts/releases">下载地址</a>
    ·
    <a href="https://github.com/bigbugcc/OpenWrts/actions">Action</a>
    ·
    <a href="https://github.com/bigbugcc/OpenWrts/issues">提出新特性</a>
  </p>

</p>

## 目录

- [Action Openwrt 云自动编译](#action-openwrt-云自动编译)
  - [目录](#目录)
  - [支持的设备](#支持的设备)
    - [🎯固件默认设置](#固件默认设置)
  - [固件特性](#固件特性)
  - [自带插件](#自带插件)
  - [文件目录说明](#文件目录说明)
  - [定制固件](#定制固件)
    - [注意事项](#注意事项)
  - [固件预览](#固件预览)
  - [版权说明](#版权说明)
  - [项目支持](#项目支持)
  - [Stargazers over time](#stargazers-over-time)

<br>

## 📢 新功能：动态源选择

🎉 现在所有工作流都支持通过 `REPO` 环境变量动态选择 OpenWrt 源代码仓库！

支持的源：
- **lede** - [Lean's LEDE](https://github.com/coolsnowwolf/lede) (默认)
- **immortalwrt** - [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)

**使用方法**：编辑工作流文件 (`.github/workflows/*.yml`) 中的 `REPO` 字段：
```yaml
env:
  REPO: lede  # 修改为 'lede' 或 'immortalwrt'
```

详细说明请查看：[源代码仓库选择指南](./docs/REPO_SELECTION.md)

<br>

## 支持的设备
|           支持的设备        |         固类别         |        Action         |            状态          |              下载页          |
| :------------------------: | :---------------------: | :-------------------: | :-------------------: | :--------------------------: |
|             x86_64                    |  [LEDE](https://github.com/coolsnowwolf/lede) |[🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/x86_64.yml) | ![x86_64](https://github.com/bigbugcc/openwrts/actions/workflows/x86_64.yml/badge.svg) |  [✔](https://github.com/bigbugcc/OpenWrts/releases) |
| x86_64Lite | [LEDE](https://github.com/coolsnowwolf/lede) |[🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/x86_64Lite.yml) | ![x86_64Lite](https://github.com/bigbugcc/openwrts/actions/workflows/x86_64Lite.yml/badge.svg) | [✔](https://github.com/bigbugcc/OpenWrts/releases) |
|             树莓派 3B/3B+             | [LEDE](https://github.com/coolsnowwolf/lede) | [🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/RaspberryPi3.yml) | ![RaspberryPi3](https://github.com/bigbugcc/openwrts/actions/workflows/RaspberryPi3.yml/badge.svg) | [✔](https://github.com/bigbugcc/OpenWrts/releases) |
|             树莓派 4B             |  [LEDE](https://github.com/coolsnowwolf/lede) | [🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/RaspberryPi4.yml) | ![RaspberryPi4](https://github.com/bigbugcc/openwrts/actions/workflows/RaspberryPi4.yml/badge.svg) |  [✔](https://github.com/bigbugcc/OpenWrts/releases) |
|             树莓派 5             |  [LEDE](https://github.com/coolsnowwolf/lede) | [🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/RaspberryPi5.yml) | ![RaspberryPi5](https://github.com/bigbugcc/openwrts/actions/workflows/RaspberryPi5.yml/badge.svg) |  [✔](https://github.com/bigbugcc/OpenWrts/releases) |
|             NanoPi R2S             |  [LEDE](https://github.com/coolsnowwolf/lede) | [🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/Rockchip.yml) | ![R2S](https://github.com/bigbugcc/openwrts/actions/workflows/Rockchip.yml/badge.svg) | [✔](https://github.com/bigbugcc/OpenWrts/releases) |
|             NanoPi R4S             |  [LEDE](https://github.com/coolsnowwolf/lede) | [🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/Rockchip.yml) | ![R4S](https://github.com/bigbugcc/openwrts/actions/workflows/Rockchip.yml/badge.svg) | [✔](https://github.com/bigbugcc/OpenWrts/releases) |
|             NanoPi R5C             |  [LEDE](https://github.com/coolsnowwolf/lede) | [🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/Rockchip.yml) | ![R5C](https://github.com/bigbugcc/openwrts/actions/workflows/Rockchip.yml/badge.svg) | [✔](https://github.com/bigbugcc/OpenWrts/releases) |
|             NanoPi R5S             |  [LEDE](https://github.com/coolsnowwolf/lede) | [🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/Rockchip.yml) | ![R5S](https://github.com/bigbugcc/openwrts/actions/workflows/Rockchip.yml/badge.svg) | [✔](https://github.com/bigbugcc/OpenWrts/releases) |
|             FastRhino R68S             |  [LEDE](https://github.com/coolsnowwolf/lede) | [🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/Rockchip.yml) | ![R68S](https://github.com/bigbugcc/openwrts/actions/workflows/Rockchip.yml/badge.svg) | [✔](https://github.com/bigbugcc/OpenWrts/releases) |
|             Orange Pi R1 Plus             |  [LEDE](https://github.com/coolsnowwolf/lede) | [🍕](https://github.com/bigbugcc/OpenWrts/actions/workflows/Rockchip.yml) | ![OrangePiR1](https://github.com/bigbugcc/openwrts/actions/workflows/Rockchip.yml/badge.svg) | [✔](https://github.com/bigbugcc/OpenWrts/releases) |

<br>

### 🎯固件默认设置
- 路由器地址: `192.168.10.1`
- 默认用户名: `root`
- 默认密码  : `password`

<br>

## 固件特性
⏰ 固件编译改为`周更`(稳定为主，减少资源浪费)

✨ iStore应用商店 [AppStore](./assets/images/appstore.png)

✨ 自带常用的插件

✨ Arm集成所有openwrt的USB驱动

✨ ~~集成Python3.x(带pip)环境~~

✨ 集成Docker-CE

✨ ~~集成Node.js(14.xLTS 带npm、yarn)~~

✨ 全新的 [Them](https://github.com/jerrykuku/luci-theme-argon)

✨ x86_64 vmdk固件集成vm-tools

✨ x86_64 iso格式镜像

✨ x86_64 Lite版本(必要插件&应用商店)

<br>

## 自带插件
🍕 默认插件
- PassWall2 / SSR Plus / OpenClash
- AdGuard Home
- Mentohust
- ~~luci-app-vssr~~
- luci-adbyby-plus
- luci-app-unblockmusic
- luci-app-ddns
- luci-app-pushbot (全能推送)
- luci-app-onliner
- luci-app-ttyd
- luci-app-turboacc
- luci-app-upnp
- luci-app-netdata
- luci-usb-printer
- luci-app-nps
- luci-app-frpc
- luci-app-n2n
- luci-app-syncdial (多播插件)
- luci-app-turboacc
- luci-app-kms
- luci-app-docker
- luci-app-serverchan
- luci-app-control-timewol (定时wol唤醒)
- luci-app-aliyundrive-webdav (阿里云盘)
- luci-app-filebrowser
- luci-app-nfs   
......

<br>

## 文件目录说明
eg:

```
filetree
├── .github/workflows
│  ├── Rockchip.yml
│  ├── RaspberryPi3.yml
│  ├── RaspberryPi4.yml
│  ├── RaspberryPi5.yml
│  ├── x86_64.yml
│  ├── x86_64Lite.yml
│  ├── update-checker.yml
├── /configs/ (配置文件目录)   
│  ├── /luci/ (app插件配置)   
│  |  ├── Lite.config (简洁配置)   
│  |  ├── Standard.config (标准配置 大量插件)
│  ├── RPi3.config
│  ├── RPi4.config
│  ├── RPi5.config
│  ├── x86_64.config
│  ├── Rockchip.config
├── yum.sh (源代码克隆脚本 - 根据REPO变量克隆lede或immortalwrt源)
├── configure.sh (固件参数修改)
├── package.sh (luci-app)

Tips:
yum.sh - 源代码克隆脚本，根据环境变量REPO选择克隆lede或immortalwrt源
x86.conf | RPi4.config - 该类型配置文件主要为机型配置文件
Standard.conf / Lite.config - 主要用于配置固件插件应用 
configure.sh - 用于修改默认系统设置（如IP地址）和添加feeds源
package.sh - 用于克隆和安装额外的luci应用插件
```
<br>

## 定制固件
1. Fork 此项目
2. 按需修改 ```yum.sh```（源选择）、```configure.sh```（系统设置） 和 ```package.sh```（插件） 文件
3. 上传你自己的 ```xx.config``` 配置文件到configs目录
4. 添加或修改自己的``````xx.yml``````文件
5. 最后根据个人喜好修改 ```update-checker.yml``` 需自行添加 ```Actions secrets``` (触发自动编译)

### 注意事项：
📌 选择源代码仓库 👉 ```yum.sh``` 中的 REPO 变量 或工作流中的 REPO 环境变量   
📌 修改默认系统参数 👉 ```configure.sh```   
📌 添加其它Luci插件 👉 ```package.sh```   
📌 插件 / 应用配置文件 👉 ```configs/Standard.config```   
<br>

## 固件预览
**主界面(主题一)：**
![主界面](./assets/images/openwrt.png)

**应用商店/插件**
![应用商店/插件](./assets/images/appstore.png)

**服务/插件：**
![服务/插件](./assets/images/service.png)

**网络：**
![网络](./assets/images/network.png)

**经典主题二：**
![登录页](./assets/images/infinityfreedom-theme.png)

**主界面：**
![主界面](./assets/images/infinityfreedom-theme-main.png)


## 版权说明

该项目签署了MIT 授权许可，详情请参阅 [LICENSE](https://github.com/bigbugcc/OpenWrts/blob/main/LICENSE)


## 项目支持
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon)
- [istore](https://github.com/linkease/istore)

## Stargazers over time
[![Stargazers over time](https://starchart.cc/bigbugcc/OpenWrts.svg)](https://starchart.cc/bigbugcc/OpenWrts)

<!-- links -->
[your-project-path]:https://github.com/bigbugcc/OpenWrts/
[contributors-shield]: https://img.shields.io/github/contributors/bigbugcc/OpenWrts?style=flat-square
[contributors-url]: https://github.com/bigbugcc/OpenWrts/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/bigbugcc/OpenWrts?style=flat-square
[forks-url]: https://github.com/bigbugcc/OpenWrts/network/members
[stars-shield]: https://img.shields.io/github/stars/bigbugcc/OpenWrts?style=flat-square
[stars-url]: https://github.com/bigbugcc/OpenWrts/stargazers
[issues-shield]: https://img.shields.io/github/issues/bigbugcc/OpenWrts?style=flat-square
[issues-url]: https://img.shields.io/github/issues/bigbugcc/OpenWrts
[license-shield]: https://img.shields.io/github/license/bigbugcc/OpenWrts?style=flat-square
[license-url]: https://github.com/bigbugcc/OpenWrts/blob/master/LICENSE