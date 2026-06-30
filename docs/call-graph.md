# OpenWrts 当前调用图

本文基于当前仓库结构生成，覆盖 GitHub Actions、Node.js 控制脚本、Bash 执行脚本、manifest/config/feeds/packages 输入，以及 artifact/release 输出链路。

## 总调用图

```mermaid
flowchart TD
    ManualTrigger["手动触发<br/>manual-build.yml<br/>workflow_dispatch"] --> ManualInputs["repo/device/flavor/branch/upload_release"]
    ScheduleTrigger["定时触发<br/>schedule-release.yml<br/>cron: 23 16 * * 6"] --> ScheduleResolveJob
    ScheduledDispatch["手动触发<br/>schedule-release.yml<br/>workflow_dispatch"] --> ScheduleInputs["repo/upload_release"]

    ManualInputs --> ManualResolveJob["manual-build.yml<br/>jobs.resolve"]
    ScheduleInputs --> ScheduleResolveJob["schedule-release.yml<br/>jobs.resolve"]

    ManualResolveJob --> CheckoutA["actions/checkout@v4"]
    ScheduleResolveJob --> CheckoutB["actions/checkout@v4"]

    CheckoutA --> ValidateA["node scripts/openwrts.mjs<br/>validate-manifest"]
    CheckoutB --> ValidateB["node scripts/openwrts.mjs<br/>validate-manifest"]
    ValidateA --> WorkflowCheckA["node scripts/openwrts.mjs<br/>generate-workflows --check"]
    ValidateB --> WorkflowCheckB["node scripts/openwrts.mjs<br/>generate-workflows --check"]

    Manifest["manifests/builds.json"] --> ValidateA
    Manifest --> ValidateB
    Manifest --> MatrixA
    Manifest --> MatrixB

    WorkflowCheckA --> MatrixA["node scripts/openwrts.mjs<br/>resolve-matrix"]
    WorkflowCheckB --> MatrixB["node scripts/openwrts.mjs<br/>resolve-matrix"]

    MatrixA --> MatrixOutputA["GITHUB_OUTPUT<br/>repo + matrix JSON"]
    MatrixB --> MatrixOutputB["GITHUB_OUTPUT<br/>repo + matrix JSON + upload_release"]

    MatrixOutputA --> Reusable["build-openwrt.yml<br/>workflow_call"]
    MatrixOutputB --> Reusable

    Reusable --> BuildJob["jobs.build<br/>ubuntu-22.04"]
    BuildJob --> CheckoutC["actions/checkout@v4"]
    CheckoutC --> PrepareEnv["scripts/prepare-env.sh"]
    PrepareEnv --> AptDeps["apt install<br/>repo-specific build deps"]

    AptDeps --> CloneStep["Clone source code"]
    CloneStep --> CloneScript["scripts/clone-source.sh"]
    CloneScript --> RepoUrl["node scripts/openwrts.mjs<br/>repo-url --repo $REPO"]
    RepoUrl --> Manifest
    RepoUrl --> GitClone["git clone --depth 1<br/>$REPO_URL -b $REPO_BRANCH"]
    GitClone --> OpenWrtTree["/mnt/workdir/openwrt"]

    OpenWrtTree --> Cache["actions/cache@v4<br/>dl + .ccache"]
    Cache --> ApplyBase["scripts/apply-openwrt.sh<br/>system feeds"]
    ApplyBase --> ConfigGenerate["package/base-files/files/bin/config_generate<br/>LAN IP 192.168.10.1"]
    ApplyBase --> FeedAppend["append feeds/$REPO.conf<br/>to feeds.conf.default"]
    Feeds["feeds/lede.conf<br/>feeds/immortalwrt.conf"] --> FeedAppend

    FeedAppend --> FeedsUpdate["./scripts/feeds update -a"]
    FeedsUpdate --> FeedsInstall["./scripts/feeds install -a"]
    FeedsInstall --> ApplyPackages["scripts/apply-openwrt.sh<br/>packages"]
    ApplyPackages --> RepoPackageScript["packages/$REPO.sh"]
    RepoPackageScript --> PackageClones["git clone third-party packages<br/>into OpenWrt package tree"]

    PackageClones --> Compose["scripts/compose-config.sh"]
    TargetCfg["configs/targets/$REPO/*.config"] --> Compose
    AppCfg["configs/apps/$REPO/*.config"] --> Compose
    DriverCfg["configs/drivers/$REPO/*.config"] --> Compose
    FilesDir["optional files/"] --> Compose
    Compose --> DotConfig["openwrt/.config"]
    DotConfig --> Defconfig1["make defconfig"]
    Defconfig1 --> DisableDefaultLuci["unset CONFIG_DEFAULT_luci*"]
    DisableDefaultLuci --> Defconfig2["make defconfig"]

    Defconfig2 --> BuildDownload["scripts/build.sh download"]
    BuildDownload --> BuildTools["scripts/build.sh tools"]
    BuildTools --> BuildToolchain["scripts/build.sh toolchain"]
    BuildToolchain --> BuildTarget["scripts/build.sh target"]
    BuildTarget --> BuildPackages["scripts/build.sh packages"]
    BuildPackages --> BuildImages["scripts/build.sh images"]

    BuildImages --> Organize["Organize files<br/>find bin/targets/*/*"]
    Organize --> Artifact["actions/upload-artifact@v4"]
    Organize --> ReleaseBody["Generate release body"]
    ReleaseBody --> Release["softprops/action-gh-release@v1"]
```

## Node.js CLI 调用图

```mermaid
flowchart TD
    CLI["scripts/openwrts.mjs"] --> Main["main()"]
    Main --> ParseArgs["parseArgs(argv)"]
    Main --> Dispatch{"command"}

    Dispatch --> ResolveMatrix["resolve-matrix"]
    Dispatch --> ValidateManifest["validate-manifest"]
    Dispatch --> GenerateWorkflows["generate-workflows"]
    Dispatch --> RepoUrl["repo-url"]
    Dispatch --> Usage["usage()"]

    ResolveMatrix --> ReadManifestA["readManifest()"]
    ResolveMatrix --> ScheduledRepo["scheduledRepo()"]
    ResolveMatrix --> MatchingItems["matchingItems()"]
    ResolveMatrix --> AvailableMatches["availableMatches()<br/>only on no match"]
    ResolveMatrix --> GithubOutput{"GITHUB_OUTPUT?"}
    GithubOutput --> WriteOutput["appendFileSync(GITHUB_OUTPUT)"]
    GithubOutput --> PrintOutput["console.log(JSON)"]

    ValidateManifest --> ReadManifestB["readManifest()"]
    ValidateManifest --> ValidateDataA["validateManifestData()"]

    GenerateWorkflows --> ReadManifestC["readManifest()"]
    GenerateWorkflows --> ValidateDataB["validateManifestData()"]
    GenerateWorkflows --> GeneratedWorkflows["generatedWorkflows()"]
    GeneratedWorkflows --> ManualWorkflow["manualWorkflow()"]
    GeneratedWorkflows --> ScheduledWorkflow["scheduledWorkflow()"]
    ManualWorkflow --> ManifestValuesA["manifestValues()"]
    ScheduledWorkflow --> ManifestValuesB["manifestValues()"]
    ManifestValuesA --> UniqueValuesA["uniqueValues()"]
    ManifestValuesB --> UniqueValuesB["uniqueValues()"]
    ManualWorkflow --> YamlOptionsA["yamlOptions()"]
    ScheduledWorkflow --> YamlOptionsB["yamlOptions()"]
    ManualWorkflow --> GeneratedHeaderA["generatedHeader()"]
    ScheduledWorkflow --> GeneratedHeaderB["generatedHeader()"]
    GenerateWorkflows --> CheckMode{"--check?"}
    CheckMode --> CompareOnly["compare current files<br/>fail if out of date"]
    CheckMode --> WriteWorkflows["writeFileSync(workflow files)"]

    RepoUrl --> ReadManifestD["readManifest()"]
    RepoUrl --> PrintRepoUrl["console.log(builds[repo].url)"]
```

## Bash 脚本调用图

```mermaid
flowchart TD
    BuildWorkflow["build-openwrt.yml"] --> Prepare["scripts/prepare-env.sh"]
    BuildWorkflow --> Clone["scripts/clone-source.sh"]
    BuildWorkflow --> Apply["scripts/apply-openwrt.sh"]
    BuildWorkflow --> Compose["scripts/compose-config.sh"]
    BuildWorkflow --> Build["scripts/build.sh"]

    Prepare --> RepoCase["case $REPO"]
    RepoCase --> AptLede["apt install LEDE deps"]
    RepoCase --> AptImmortal["apt install ImmortalWrt deps"]

    Clone --> RepoUrlCall["node scripts/openwrts.mjs repo-url"]
    RepoUrlCall --> GitClone["git clone --depth 1"]

    Apply --> ArgParser["parse modes<br/>system/feeds/packages/all"]
    ArgParser --> ResolveOpenWrtDir["resolve_openwrt_dir()"]
    ArgParser --> ApplySystem["apply_system()"]
    ArgParser --> ApplyFeeds["apply_feeds()"]
    ArgParser --> ApplyPackages["apply_packages()"]

    ApplySystem --> SedLanIp["sed 192.168.1.1 -> 192.168.10.1"]
    ApplyFeeds --> RepoFeeds["feeds/$REPO.conf"]
    RepoFeeds --> AppendFeeds["cat >> openwrt/feeds.conf.default"]
    ApplyPackages --> PackageScript["packages/$REPO.sh"]
    PackageScript --> ClonePackage["clone_package(repo_url, dest)"]
    ClonePackage --> PackageGitClone["git clone --depth 1"]

    Compose --> ResolveTarget["resolve_path($TARGET_CONFIG)"]
    Compose --> ResolveApp["resolve_path($APP_CONFIG)"]
    Compose --> ResolveDriver["resolve_path($DRIVER_CONFIG)"]
    Compose --> CopyFiles["copy optional root files/"]
    Compose --> WriteConfig["cat target + driver + app<br/>to openwrt/.config"]
    WriteConfig --> MakeDefconfigA["make defconfig"]
    MakeDefconfigA --> AwkDefaultLuci["awk unset CONFIG_DEFAULT_luci*"]
    AwkDefaultLuci --> MakeDefconfigB["make defconfig"]

    Build --> Phase{"phase"}
    Phase --> Download["download_sources()<br/>make download + remove tiny dl files"]
    Phase --> Tools["run_make tools/install"]
    Phase --> Toolchain["run_make toolchain/install"]
    Phase --> Target["run_make target/compile"]
    Phase --> Packages["run_make package/compile"]
    Phase --> Images["run_make package/install<br/>target/install<br/>package/index"]
    Phase --> All["download_sources()<br/>run_make world"]
```

## 调用关系速查

| Caller | Callee | Purpose |
| --- | --- | --- |
| `manual-build.yml` | `node scripts/openwrts.mjs validate-manifest` | Validate manifest before resolving manual matrix. |
| `manual-build.yml` | `node scripts/openwrts.mjs generate-workflows --check` | Ensure generated workflow options are committed. |
| `manual-build.yml` | `node scripts/openwrts.mjs resolve-matrix` | Convert manual inputs into matrix JSON. |
| `schedule-release.yml` | `node scripts/openwrts.mjs resolve-matrix` | Resolve scheduled repo rotation or selected repo. |
| `build-openwrt.yml` | `scripts/prepare-env.sh` | Install build dependencies. |
| `build-openwrt.yml` | `scripts/clone-source.sh` | Clone selected upstream OpenWrt source. |
| `scripts/clone-source.sh` | `node scripts/openwrts.mjs repo-url` | Resolve upstream URL from manifest. |
| `build-openwrt.yml` | `scripts/apply-openwrt.sh system feeds` | Apply LAN IP default and append feeds. |
| `build-openwrt.yml` | `./scripts/feeds update -a` | Update OpenWrt feeds inside upstream tree. |
| `build-openwrt.yml` | `./scripts/feeds install -a` | Install OpenWrt feed packages inside upstream tree. |
| `build-openwrt.yml` | `scripts/apply-openwrt.sh packages` | Clone repo-specific third-party packages. |
| `scripts/apply-openwrt.sh` | `packages/<repo>.sh` | Run package clone script for selected repo. |
| `build-openwrt.yml` | `scripts/compose-config.sh` | Compose final OpenWrt `.config`. |
| `build-openwrt.yml` | `scripts/build.sh <phase>` | Run staged OpenWrt build phases. |
