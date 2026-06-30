# OpenWrts

[English](./README.md) | [简体中文](./README.zh-CN.md)

OpenWrts builds OpenWrt firmware with GitHub Actions. The default documentation language is English; a Chinese version is available above.

<p align="center">
  <img src="./assets/images/action1.jpg" alt="OpenWrts" width="500" />
</p>

![Scheduled Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/schedule-release.yml/badge.svg)
![Manual Build](https://github.com/bigbugcc/OpenWrts/actions/workflows/manual-build.yml/badge.svg)
![Release Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square)
![Latest Release](https://img.shields.io/github/v/release/bigbugcc/OpenWrts?style=flat-square)
![License](https://img.shields.io/github/license/bigbugcc/OpenWrts?style=flat-square)

## Firmware Builds

The firmware build list is maintained in [`manifests/builds.json`](./manifests/builds.json). The scheduled workflow controls timed releases and alternates between LEDE and ImmortalWrt in `auto` mode.

| Source | Device ID | Platform | Flavor | Workflow status | Downloads |
| --- | --- | --- | --- | --- | --- |
| `lede` | `x86_64` | x86_64 generic | `standard` | ![Scheduled Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/schedule-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |
| `lede` | `rpi3` | Raspberry Pi 3B/3B+ | `standard` | ![Scheduled Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/schedule-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |
| `lede` | `rpi4` | Raspberry Pi 4B | `standard` | ![Scheduled Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/schedule-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |
| `lede` | `rpi5` | Raspberry Pi 5 | `standard` | ![Scheduled Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/schedule-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |
| `lede` | `rockchip` | R68S, NanoPi R2S/R4S/R5C/R5S, Orange Pi R1 Plus | `standard` | ![Scheduled Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/schedule-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |
| `immortalwrt` | `x86_64` | x86_64 generic | `lite` | ![Scheduled Release](https://github.com/bigbugcc/OpenWrts/actions/workflows/schedule-release.yml/badge.svg) | ![Downloads](https://img.shields.io/github/downloads/bigbugcc/OpenWrts/total?style=flat-square) |

## LuCI Plugins

### LEDE Standard

| Category | Plugins |
| --- | --- |
| Store and proxy | `luci-app-store`, `luci-app-openclash`, `luci-app-passwall2`, `luci-app-ssr-plus` |
| Network | `luci-app-ddns`, `luci-app-mwan3`, `luci-app-n2n`, `luci-app-openvpn`, `luci-app-softethervpn`, `luci-app-syncdial`, `luci-app-upnp`, `luci-app-wireguard`, `luci-app-zerotier`, `luci-app-smartdns` |
| Services | `luci-app-adguardhome`, `luci-app-docker`, `luci-app-dockerman`, `luci-app-filebrowser`, `luci-app-frpc`, `luci-app-nfs`, `luci-app-nps`, `luci-app-samba4`, `luci-app-ttyd`, `luci-app-vsftpd` |
| System and tools | `luci-app-accesscontrol`, `luci-app-arpbind`, `luci-app-autoreboot`, `luci-app-cifs-mount`, `luci-app-commands`, `luci-app-control-timewol`, `luci-app-diskman`, `luci-app-filetransfer`, `luci-app-firewall`, `luci-app-netdata`, `luci-app-nlbwmon`, `luci-app-onliner`, `luci-app-pushbot`, `luci-app-qos`, `luci-app-serverchan`, `luci-app-usb-printer`, `luci-app-vlmcsd`, `luci-app-wol` |
| Extra apps | `luci-app-ipsec-vpnd`, `luci-app-mentohust`, `luci-app-oaf`, `luci-app-qbittorrent_static`, `luci-app-qbittorrent-simple_dynamic`, `luci-app-turboacc` |
| Themes | `luci-theme-argon`, `luci-theme-bootstrap`, `luci-theme-infinityfreedom`, `luci-theme-material`, `luci-theme-netgear`, `luci-theme-neobird` |

### ImmortalWrt Lite

| Category | Plugins |
| --- | --- |
| Store and proxy | `luci-app-store`, `luci-app-openclash`, `luci-app-passwall2`, `luci-app-ssr-plus` |
| Network | `luci-app-accesscontrol`, `luci-app-smartdns`, `luci-app-turboacc`, `luci-proto-wireguard` |
| Services | `luci-app-docker`, `luci-app-dockerman`, `luci-app-filetransfer`, `luci-app-firewall`, `luci-app-netdata`, `luci-app-oaf`, `luci-app-onliner`, `luci-app-ttyd` |
| System defaults | `default-settings`, `default-settings-chn`, `luci-app-autoreboot` |
| Themes | `luci-theme-argon`, `luci-theme-bootstrap`, `luci-theme-material` |

## Supported Sources

| Source ID | Upstream repository | Default branch | Notes |
| --- | --- | --- | --- |
| `lede` | <https://github.com/coolsnowwolf/lede> | `master` | Lean LEDE, currently used for standard builds |
| `immortalwrt` | <https://github.com/immortalwrt/immortalwrt> | `master` | ImmortalWrt, currently used for the x86_64 lite build |

The two sources do not share the same SDK, feeds, LuCI version, package set, or plugin compatibility guarantees. Application configs and package scripts are therefore source-specific.

## Workflows

| Workflow | Purpose |
| --- | --- |
| [`schedule-release.yml`](./.github/workflows/schedule-release.yml) | Scheduled release. `auto` mode alternates between LEDE and ImmortalWrt by ISO week parity |
| [`manual-build.yml`](./.github/workflows/manual-build.yml) | Manual build entry point with source, device, flavor, branch, and release controls |
| [`build-openwrt.yml`](./.github/workflows/build-openwrt.yml) | Reusable workflow that builds one matrix item |

The scheduled workflow uses UTC:

```yaml
schedule:
  - cron: "23 16 * * 6"
```

This is roughly Sunday 00:23 in Asia/Shanghai.

## Build Flow

```text
scheduled/manual workflow
  -> scripts/resolve-matrix.py generates the build matrix
  -> build-openwrt.yml
     -> scripts/prepare-env.sh
     -> scripts/clone-source.sh
     -> scripts/apply-system.sh
     -> scripts/apply-feeds.sh
     -> scripts/apply-packages.sh
     -> scripts/compose-config.sh
     -> scripts/build.sh
     -> upload artifact / release
```

## Repository Layout

```text
.github/workflows/
  build-openwrt.yml      reusable build workflow
  schedule-release.yml   scheduled source-rotation release workflow
  manual-build.yml       manual build workflow

manifests/
  builds.json            build matrix definition

feeds/
  lede.conf              LEDE feeds
  immortalwrt.conf       ImmortalWrt feeds

packages/
  lede.sh                LEDE third-party packages
  immortalwrt.sh         ImmortalWrt third-party packages

configs/
  targets/               source-specific target/device configs
  apps/                  source-specific LuCI app configs
  drivers/               source-specific driver extension configs

scripts/
  prepare-env.sh         install build dependencies
  clone-source.sh        clone the selected upstream source
  apply-system.sh        apply default system settings
  apply-feeds.sh         append source-specific feeds
  apply-packages.sh      clone source-specific third-party packages
  compose-config.sh      compose .config and run make defconfig
  build.sh               download dependencies and compile firmware
  resolve-matrix.py      parse manifests/builds.json
```

The root-level `source.sh`, `environment.sh`, `configure.sh`, and `package.sh` files are compatibility wrappers. They forward to the newer scripts under `scripts/`.

## Cache Strategy

The new workflow caches `dl` and `.ccache` with `actions/cache`. The cache key includes:

```text
repo + branch + cache_scope + hash(feeds/packages/scripts/configs/manifests)
```

This avoids reusing incompatible cache data across LEDE, ImmortalWrt, devices, and firmware flavors.

## Default Firmware Settings

- Management IP: `192.168.10.1`
- User: `root`
- Password: `password`

## Manual Builds

Open GitHub Actions and run `Manual OpenWrt Build`, then choose:

- `repo`: `auto`, `lede`, or `immortalwrt`. Use `auto` to resolve the source from the selected device; for `device=all`, `auto` follows the scheduled rotation rule.
- `device`: `all` or a device ID from the matrix
- `flavor`: `all`, `standard`, or `lite`
- `branch`: leave empty to use the manifest default, or provide an upstream branch
- `upload_release`: whether to upload firmware to GitHub Releases

## Local Matrix Checks

```powershell
python scripts\resolve-matrix.py --repo lede --device x86_64
python scripts\resolve-matrix.py --repo immortalwrt --device all
python scripts\resolve-matrix.py --repo auto
```

If Python is not available in `PATH`, run the script with the full path to your Python executable.

## Adding a Device

1. Add the target/device config under `configs/targets/<repo>/`.
2. Add or reuse an app config under `configs/apps/<repo>/`.
3. Add driver extensions under `configs/drivers/<repo>/` when needed.
4. Add the device entry to `manifests/builds.json`.
5. Update `packages/<repo>.sh` if the device needs extra packages.

## Screenshots

![OpenWrt](./assets/images/openwrt.png)

![App Store](./assets/images/appstore.png)

![Service](./assets/images/service.png)

![Network](./assets/images/network.png)

## Credits

- <https://github.com/P3TERX/Actions-OpenWrt>
- <https://github.com/coolsnowwolf/lede>
- <https://github.com/immortalwrt/immortalwrt>
- <https://github.com/jerrykuku/luci-theme-argon>
- <https://github.com/linkease/istore>

## License

This project is released under the MIT License. See [`LICENSE`](./LICENSE).
