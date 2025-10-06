# OpenWrt 源代码仓库选择说明

## 概述

所有 GitHub Actions 工作流现在支持通过 `REPO` 环境变量动态选择 OpenWrt 源代码仓库。

## 支持的源仓库

当前支持以下两个源代码仓库：

| REPO 值 | 仓库地址 | 描述 |
|---------|---------|------|
| `lede` | https://github.com/coolsnowwolf/lede | Lean's LEDE (默认) |
| `immortalwrt` | https://github.com/immortalwrt/immortalwrt | ImmortalWrt |

## 使用方法

### 方法 1: 修改工作流文件

编辑相应的工作流文件 (`.github/workflows/*.yml`)，修改 `env` 部分的 `REPO` 值：

```yaml
env:
  OPNAME: 'x86_64'
  REPO: lede  # 将此值改为 'lede' 或 'immortalwrt'
  REPO_BRANCH: master
  CLONE_SH: yum.sh  # 克隆脚本
```

#### 使用 Lean's LEDE 源

```yaml
env:
  REPO: lede
  REPO_BRANCH: master
```

#### 使用 ImmortalWrt 源

```yaml
env:
  REPO: immortalwrt
  REPO_BRANCH: master
```

### 方法 2: 手动触发工作流

1. 进入 GitHub 仓库页面
2. 点击 "Actions" 标签
3. 选择要运行的工作流 (如 x86_64)
4. 点击 "Run workflow"
5. 在运行之前，可以先修改对应的 workflow 文件中的 `REPO` 值

## 工作流列表

以下工作流均已支持动态源选择：

- ✅ x86_64
- ✅ x86_64Lite
- ✅ Raspberry Pi3B+
- ✅ Raspberry Pi4
- ✅ Raspberry Pi5
- ✅ Rockchip (R68S、R2S、R4S、R5C、R5S、OPiR1Plus)

## 实现原理

克隆步骤通过 `yum.sh` 脚本执行，脚本会根据 `REPO` 环境变量的值动态选择源仓库：

**工作流中的使用：**
```yaml
- name: Clone source code
  working-directory: /mnt/workdir
  run: |
    chmod +x $GITHUB_WORKSPACE/$CLONE_SH
    $GITHUB_WORKSPACE/$CLONE_SH openwrt
    ln -sf /mnt/workdir/openwrt $GITHUB_WORKSPACE/openwrt
```

## 注意事项

1. **默认源**: 如果不修改，默认使用 `lede` 源
2. **分支选择**: 可以通过 `REPO_BRANCH` 环境变量修改分支，默认为 `master`
3. **配置兼容性**: 不同源的配置选项可能有差异，请确保配置文件与所选源兼容
4. **构建时间**: 不同源的构建时间可能有所不同

## 示例

### 为 x86_64 使用 ImmortalWrt 源

编辑 `.github/workflows/x86_64.yml`:

```yaml
env:
  OPNAME: 'x86_64'
  REPO: immortalwrt  # 修改为 immortalwrt
  REPO_BRANCH: master  # 或其他分支如 'openwrt-23.05'
  CLONE_SH: yum.sh
  FEEDS_CONF: feeds.conf.default
  EXTERNAL_FILE: configs/luci/Standard.config
  CONFIG_FILE: configs/x86_64.config
  # ... 其他配置
```

### 为 Raspberry Pi 使用特定分支

```yaml
env:
  OPNAME: 'Raspberry Pi4'
  REPO: immortalwrt
  REPO_BRANCH: openwrt-23.05  # 使用特定分支
  CLONE_SH: yum.sh
  # ... 其他配置
```

## 本地使用

您也可以在本地直接使用 `yum.sh` 脚本克隆源代码：

```bash
# 使用 lede 源（默认）
export REPO=lede
export REPO_BRANCH=master
./yum.sh

# 使用 immortalwrt 源
export REPO=immortalwrt
export REPO_BRANCH=master
./yum.sh

# 指定克隆目录
./yum.sh my-openwrt-dir
```

## 扩展其他源

如需添加其他 OpenWrt 源，请修改 `yum.sh` 脚本，添加新的 elif 条件：

```bash
elif [ "$REPO" = "新源名称" ]; then
    REPO_URL="https://github.com/用户名/仓库名"
    echo "✓ Using 新源名称 source"
```

## 文件说明

- **yum.sh** - 源代码克隆脚本，根据 `REPO` 环境变量选择并克隆相应的源代码仓库
- **configure.sh** - 系统配置脚本，用于修改默认设置和添加 feeds
- **package.sh** - 插件安装脚本，用于克隆和安装额外的应用插件

## 问题排查

如果构建失败，请检查：

1. `REPO` 值是否正确 (只能是 `lede` 或 `immortalwrt`)
2. `REPO_BRANCH` 分支是否存在
3. 配置文件是否与所选源兼容
4. 查看 Actions 日志中的 "Clone source code" 步骤，确认克隆的仓库地址是否正确
