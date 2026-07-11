#!/usr/bin/env node
import { appendFileSync, existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = resolve(__dirname, "..");
const defaultManifestPath = "manifests/builds.json";
const commonConfigRepo = "common";
const repoDefaults = {
  lede: {
    branch: "master",
    url: "https://github.com/coolsnowwolf/lede",
  },
  immortalwrt: {
    branch: "master",
    url: "https://github.com/immortalwrt/immortalwrt",
  },
};

function usage() {
  console.error(`Usage:
  node scripts/openwrts.mjs resolve-matrix [--manifest path] [--repo auto|lede|immortalwrt] [--device all|id | --devices all|id,id] [--flavor all|name | --flavors all|name,name] [--branch name]
  node scripts/openwrts.mjs validate-manifest [--manifest path]
  node scripts/openwrts.mjs generate-workflows [--manifest path] [--check]
  node scripts/openwrts.mjs repo-url --repo lede|immortalwrt [--manifest path]`);
}

function parseArgs(argv) {
  const args = { _: [] };

  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];

    if (!token.startsWith("--")) {
      args._.push(token);
      continue;
    }

    const eqIndex = token.indexOf("=");
    if (eqIndex !== -1) {
      args[token.slice(2, eqIndex)] = token.slice(eqIndex + 1);
      continue;
    }

    const key = token.slice(2);
    const next = argv[index + 1];
    if (next === undefined || next.startsWith("--")) {
      args[key] = true;
      continue;
    }

    args[key] = next;
    index += 1;
  }

  return args;
}

function defaultManifest() {
  return {
    workflow: {
      manual: {
        default_repo: "lede",
        default_device: "all",
        default_flavor: "standard",
      },
      schedule: {
        default_repo: "auto",
        default_devices: "all",
        default_flavors: "lite",
      },
    },
    builds: {},
  };
}

function readManifest(path = defaultManifestPath, options = {}) {
  const manifestPath = resolve(rootDir, path);
  if (!existsSync(manifestPath) && options.allowMissing) {
    return { data: defaultManifest(), manifestPath, manifestLabel: path };
  }

  const data = JSON.parse(readFileSync(manifestPath, "utf8"));
  return { data, manifestPath, manifestLabel: path };
}

function scheduledRepo(now = new Date()) {
  const date = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const day = date.getUTCDay() || 7;
  date.setUTCDate(date.getUTCDate() + 4 - day);
  const yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
  const week = Math.ceil(((date - yearStart) / 86400000 + 1) / 7);
  return week % 2 === 0 ? "lede" : "immortalwrt";
}

function parseSelection(value, label) {
  const selection = uniqueValues(
    String(value || "all")
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean),
  );

  if (selection.length === 0) {
    return ["all"];
  }
  if (selection.includes("all") && selection.length > 1) {
    throw new Error(`${label} cannot combine 'all' with other values.`);
  }

  return selection;
}

function matchingItems(data, repoNames, devices, flavors) {
  const include = [];
  const allDevices = devices.includes("all");
  const allFlavors = flavors.includes("all");

  for (const repo of repoNames) {
    const repoData = data.builds[repo];
    for (const item of repoData.devices || []) {
      if (!allDevices && !devices.includes(item.id)) {
        continue;
      }
      if (!allFlavors && !flavors.includes(item.flavor || "")) {
        continue;
      }

      include.push({ ...item, repo });
    }
  }

  return include;
}

function formatMatches(matches) {
  if (matches.length === 0) {
    return "none";
  }

  return matches.map((item) => `${item.repo}/${item.id}[${item.flavor || "unknown"}]`).join(", ");
}

function availableMatches(data, repoNames, devices, flavors) {
  return formatMatches(matchingItems(data, repoNames, devices, flavors));
}

function resolveMatrix(args) {
  const { data } = readManifest(args.manifest);
  const repoArg = args.repo || "auto";
  const devices = parseSelection(args.devices === undefined ? args.device : args.devices, "devices");
  const flavors = parseSelection(args.flavors === undefined ? args.flavor : args.flavors, "flavors");
  const branchOverride = args.branch === true ? "" : args.branch || "";

  if (repoArg !== "auto" && !data.builds[repoArg]) {
    throw new Error(`Unknown repo '${repoArg}'.`);
  }

  const repo = repoArg === "auto" ? scheduledRepo() : repoArg;
  const repoNames = [repo];
  const repoItems = repoNames.flatMap((repoName) => data.builds[repoName].devices || []);
  const knownDevices = uniqueValues(repoItems.map((item) => item.id));
  const knownFlavors = uniqueValues(repoItems.map((item) => item.flavor).filter(Boolean));
  const unknownDevices = devices.filter((item) => item !== "all" && !knownDevices.includes(item));
  const unknownFlavors = flavors.filter((item) => item !== "all" && !knownFlavors.includes(item));

  if (unknownDevices.length > 0) {
    throw new Error(`Unknown devices for repo=${repo}: ${unknownDevices.join(", ")}. Available devices: ${knownDevices.join(", ")}.`);
  }
  if (unknownFlavors.length > 0) {
    throw new Error(`Unknown flavors for repo=${repo}: ${unknownFlavors.join(", ")}. Available flavors: ${knownFlavors.join(", ")}.`);
  }

  const include = matchingItems(data, repoNames, devices, flavors);
  for (const item of include) {
    const repoData = data.builds[item.repo];
    item.branch = branchOverride || repoData.branch || "master";
  }

  if (include.length === 0) {
    const alternatives = availableMatches(data, repoNames, devices, ["all"]);
    const availableFlavors = uniqueValues(matchingItems(data, repoNames, devices, ["all"]).map((item) => item.flavor)).join(", ") || "none";
    throw new Error(
      `No builds matched repo=${repoArg}, devices=${devices.join(",")}, flavors=${flavors.join(",")}. ` +
        `Available builds for this repo/device: ${alternatives}. ` +
        `Available flavors: ${availableFlavors}.`,
    );
  }

  const repos = new Set(include.map((item) => item.repo));
  const output = {
    repo: repos.size === 1 ? include[0].repo : "multiple",
    matrix: JSON.stringify({ include }),
  };

  const githubOutput = process.env.GITHUB_OUTPUT;
  if (githubOutput) {
    appendFileSync(githubOutput, Object.entries(output).map(([key, value]) => `${key}=${value}\n`).join(""), "utf8");
  } else {
    console.log(JSON.stringify(output, null, 2));
  }
}

function uniqueValues(values) {
  return [...new Set(values)];
}

function sortedConfigNamesInDir(...segments) {
  const configDir = resolve(rootDir, ...segments);
  if (!existsSync(configDir)) {
    return [];
  }

  return readdirSync(configDir, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".config"))
    .map((entry) => entry.name.slice(0, -".config".length))
    .sort((left, right) => left.localeCompare(right));
}

function sortedConfigNames(section, repo) {
  return sortedConfigNamesInDir("configs", section, repo);
}

function sortedTargetConfigNames() {
  return sortedConfigNamesInDir("configs", "targets");
}

function sortedConfigRepos(section) {
  const configDir = resolve(rootDir, "configs", section);
  if (!existsSync(configDir)) {
    return [];
  }

  return readdirSync(configDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && entry.name !== commonConfigRepo)
    .map((entry) => entry.name)
    .sort((left, right) => left.localeCompare(right));
}

function configPath(section, repo, name) {
  return `configs/${section}/${repo}/${name}.config`;
}

function targetConfigPath(name) {
  return `configs/targets/${name}.config`;
}

function configPathForRepo(section, repo, name) {
  const repoPath = configPath(section, repo, name);
  if (existsSync(resolve(rootDir, repoPath))) {
    return repoPath;
  }

  const commonPath = configPath(section, commonConfigRepo, name);
  if (existsSync(resolve(rootDir, commonPath))) {
    return commonPath;
  }

  return repoPath;
}

function configNamesForRepo(section, repo) {
  return uniqueValues([
    ...sortedConfigNames(section, repo),
    ...sortedConfigNames(section, commonConfigRepo),
  ]).sort((left, right) => left.localeCompare(right));
}

function existingOrder(values, availableValues) {
  const available = new Set(availableValues);
  return uniqueValues(values).filter((value) => available.has(value));
}

function syncManifestData(data) {
  const builds = data.builds || {};
  const repoNames = uniqueValues([
    ...Object.keys(builds),
    ...Object.keys(repoDefaults),
    ...sortedConfigRepos("apps"),
  ]);

  const synced = {
    ...data,
    workflow: data.workflow || defaultManifest().workflow,
    builds: {},
  };

  for (const repo of repoNames) {
    const repoData = builds[repo] || {};
    const existingDevices = Array.isArray(repoData.devices) ? repoData.devices : [];
    const targetIds = sortedTargetConfigNames();
    const flavors = configNamesForRepo("apps", repo);
    const defaults = repoDefaults[repo] || {};

    if (targetIds.length === 0 || flavors.length === 0) {
      synced.builds[repo] = { ...repoData, devices: existingDevices };
      continue;
    }

    const existingByKey = new Map();
    const displayNamesByDevice = new Map();
    for (const item of existingDevices) {
      if (item.id && item.flavor) {
        existingByKey.set(`${item.id}\0${item.flavor}`, item);
      }
      if (item.id && item.op_name && !displayNamesByDevice.has(item.id)) {
        displayNamesByDevice.set(item.id, item.op_name);
      }
    }

    const targetOrder = uniqueValues([
      ...existingOrder(existingDevices.map((item) => item.id).filter(Boolean), targetIds),
      ...targetIds,
    ]);
    const flavorOrder = uniqueValues([
      ...existingOrder(existingDevices.map((item) => item.flavor).filter(Boolean), flavors),
      ...flavors,
    ]);
    const defaultDriverConfig = configPathForRepo("drivers", repo, "common");
    const hasDefaultDriver = existsSync(resolve(rootDir, defaultDriverConfig));
    const devices = [];

    for (const targetId of targetOrder) {
      for (const flavor of flavorOrder) {
        const existing = existingByKey.get(`${targetId}\0${flavor}`) || {};
        const item = {
          ...existing,
          id: targetId,
          op_name: existing.op_name || displayNamesByDevice.get(targetId) || targetId,
          flavor,
          target_config: targetConfigPath(targetId),
          app_config: configPathForRepo("apps", repo, flavor),
        };
        const driverConfig = existing.driver_config || (hasDefaultDriver ? defaultDriverConfig : "");
        if (driverConfig) {
          item.driver_config = driverConfig;
        } else {
          delete item.driver_config;
        }
        item.cache_scope = existing.cache_scope || `${repo}-${targetId}-${flavor}`;
        devices.push(item);
      }
    }

    synced.builds[repo] = {
      ...repoData,
      branch: repoData.branch || defaults.branch || "master",
      url: repoData.url || defaults.url,
      devices,
    };
  }

  return synced;
}

function manifestContent(data) {
  return `${JSON.stringify(data, null, 2)}\n`;
}

function manifestValues(data) {
  const repoNames = Object.keys(data.builds);
  const devices = [];
  const flavors = [];

  for (const repo of repoNames) {
    for (const item of data.builds[repo].devices || []) {
      devices.push(item.id);
      if (item.flavor) {
        flavors.push(item.flavor);
      }
    }
  }

  return {
    repos: ["auto", ...repoNames],
    devices: ["all", ...uniqueValues(devices)],
    flavors: [...uniqueValues(flavors), "all"],
  };
}

function manualDefaults(data, values) {
  const configured = data.workflow?.manual || {};
  return {
    repo: configured.default_repo || "auto",
    device: configured.default_device || "all",
    flavor: configured.default_flavor || (values.flavors.includes("standard") ? "standard" : values.flavors[0]),
  };
}

function scheduledDefaults(data, values) {
  const configured = data.workflow?.schedule || {};
  return {
    repo: configured.default_repo || "auto",
    devices: configured.default_devices || "all",
    flavors: configured.default_flavors || (values.flavors.includes("lite") ? "lite" : values.flavors[0]),
  };
}

function yamlOptions(values, indent = 10) {
  const pad = " ".repeat(indent);
  return values.map((value) => `${pad}- ${value}`).join("\n");
}

function generatedHeader() {
  return "# This file is generated by `node scripts/openwrts.mjs generate-workflows`.\n# Do not edit workflow input options by hand.\n";
}

function manualWorkflow(data) {
  const values = manifestValues(data);
  const defaults = manualDefaults(data, values);

  return `${generatedHeader()}name: Manual OpenWrt Build

on:
  workflow_dispatch:
    inputs:
      repo:
        description: Source repo to build. Auto selects one repo using the scheduled rotation.
        required: true
        type: choice
        options:
${yamlOptions(values.repos)}
        default: ${defaults.repo}
      device:
        description: Device id from manifests/builds.json, or all.
        required: true
        type: choice
        options:
${yamlOptions(values.devices)}
        default: ${defaults.device}
      flavor:
        description: Firmware flavor. Use all to build every matching manifest entry.
        required: true
        type: choice
        options:
${yamlOptions(values.flavors)}
        default: ${defaults.flavor}
      branch:
        description: Override upstream branch. Leave empty to use manifest default.
        required: false
        type: string
        default: ""
      upload_release:
        description: Upload firmware to GitHub Releases.
        required: true
        type: boolean
        default: false

permissions:
  contents: write

jobs:
  resolve:
    name: \${{ inputs.repo == 'lede' && 'LEDE' || inputs.repo == 'immortalwrt' && 'ImmortalWrt' || 'Auto Source' }}
    runs-on: ubuntu-22.04
    outputs:
      repo: \${{ steps.matrix.outputs.repo }}
      matrix: \${{ steps.matrix.outputs.matrix }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Validate generated workflow files
        run: |
          node scripts/openwrts.mjs validate-manifest
          node scripts/openwrts.mjs generate-workflows --check

      - name: Resolve manual build matrix
        id: matrix
        run: |
          node scripts/openwrts.mjs resolve-matrix \\
            --repo "\${{ inputs.repo }}" \\
            --device "\${{ inputs.device }}" \\
            --flavor "\${{ inputs.flavor }}" \\
            --branch "\${{ inputs.branch }}"

  build:
    needs: resolve
    strategy:
      fail-fast: false
      matrix: \${{ fromJSON(needs.resolve.outputs.matrix) }}
    name: \${{ matrix.id }} - \${{ matrix.flavor }}
    uses: ./.github/workflows/build-openwrt.yml
    with:
      repo: \${{ matrix.repo }}
      branch: \${{ matrix.branch }}
      device: \${{ matrix.id }}
      op_name: \${{ matrix.op_name }}
      flavor: \${{ matrix.flavor }}
      target_config: \${{ matrix.target_config }}
      app_config: \${{ matrix.app_config }}
      driver_config: \${{ matrix.driver_config }}
      cache_scope: \${{ matrix.cache_scope }}
      upload_release: \${{ inputs.upload_release }}
    secrets: inherit
`;
}

function scheduledWorkflow(data) {
  const values = manifestValues(data);
  const defaults = scheduledDefaults(data, values);

  return `${generatedHeader()}name: Scheduled OpenWrt Release

on:
  workflow_dispatch:
    inputs:
      repo:
        description: Source repo to build. Use auto for scheduled LEDE/ImmortalWrt rotation.
        required: true
        type: choice
        options:
${yamlOptions(values.repos)}
        default: ${defaults.repo}
      devices:
        description: Target config names, comma-separated for multiple devices, or all.
        required: true
        type: string
        default: "${defaults.devices}"
      flavors:
        description: Firmware flavors, comma-separated for multiple flavors, or all.
        required: true
        type: string
        default: "${defaults.flavors}"
      upload_release:
        description: Upload firmware to GitHub Releases.
        required: true
        type: boolean
        default: true
  schedule:
    - cron: "23 16 * * 6"

permissions:
  contents: write

jobs:
  resolve:
    name: \${{ (github.event.inputs.repo || '${defaults.repo}') == 'lede' && 'LEDE' || (github.event.inputs.repo || '${defaults.repo}') == 'immortalwrt' && 'ImmortalWrt' || 'Auto Source' }}
    runs-on: ubuntu-22.04
    outputs:
      repo: \${{ steps.matrix.outputs.repo }}
      matrix: \${{ steps.matrix.outputs.matrix }}
      upload_release: \${{ steps.matrix.outputs.upload_release }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Validate generated workflow files
        run: |
          node scripts/openwrts.mjs validate-manifest
          node scripts/openwrts.mjs generate-workflows --check

      - name: Resolve scheduled build matrix
        id: matrix
        env:
          REQUESTED_REPO: \${{ github.event.inputs.repo || '${defaults.repo}' }}
          REQUESTED_DEVICES: \${{ github.event.inputs.devices || '${defaults.devices}' }}
          REQUESTED_FLAVORS: \${{ github.event.inputs.flavors || '${defaults.flavors}' }}
          REQUESTED_UPLOAD_RELEASE: \${{ github.event.inputs.upload_release || 'true' }}
        run: |
          node scripts/openwrts.mjs resolve-matrix \\
            --repo "$REQUESTED_REPO" \\
            --devices "$REQUESTED_DEVICES" \\
            --flavors "$REQUESTED_FLAVORS"
          echo "upload_release=$REQUESTED_UPLOAD_RELEASE" >> "$GITHUB_OUTPUT"

  build:
    needs: resolve
    strategy:
      fail-fast: false
      matrix: \${{ fromJSON(needs.resolve.outputs.matrix) }}
    name: \${{ matrix.id }} - \${{ matrix.flavor }}
    uses: ./.github/workflows/build-openwrt.yml
    with:
      repo: \${{ matrix.repo }}
      branch: \${{ matrix.branch }}
      device: \${{ matrix.id }}
      op_name: \${{ matrix.op_name }}
      flavor: \${{ matrix.flavor }}
      target_config: \${{ matrix.target_config }}
      app_config: \${{ matrix.app_config }}
      driver_config: \${{ matrix.driver_config }}
      cache_scope: \${{ matrix.cache_scope }}
      upload_release: \${{ needs.resolve.outputs.upload_release == 'true' }}
    secrets: inherit
`;
}

function generatedWorkflows(data) {
  return [
    { path: ".github/workflows/manual-build.yml", content: manualWorkflow(data) },
    { path: ".github/workflows/schedule-release.yml", content: scheduledWorkflow(data) },
  ];
}

function generateWorkflows(args) {
  const { data, manifestPath, manifestLabel } = readManifest(args.manifest, { allowMissing: true });
  const syncedData = syncManifestData(data);
  validateManifestData(syncedData);
  const workflows = generatedWorkflows(syncedData);
  const check = Boolean(args.check);
  const mismatches = [];
  const currentManifest = existsSync(manifestPath) ? readFileSync(manifestPath, "utf8") : "";
  const nextManifest = manifestContent(syncedData);

  if (currentManifest !== nextManifest) {
    mismatches.push(manifestLabel);
    if (!check) {
      writeFileSync(manifestPath, nextManifest, "utf8");
    }
  }

  for (const workflow of workflows) {
    const workflowPath = resolve(rootDir, workflow.path);
    const current = existsSync(workflowPath) ? readFileSync(workflowPath, "utf8") : "";
    if (current !== workflow.content) {
      mismatches.push(workflow.path);
      if (!check) {
        writeFileSync(workflowPath, workflow.content, "utf8");
      }
    }
  }

  if (check && mismatches.length > 0) {
    throw new Error(`Generated files are out of date: ${mismatches.join(", ")}. Run node scripts/openwrts.mjs generate-workflows.`);
  }

  if (mismatches.length === 0) {
    console.log("Generated files are up to date.");
  } else if (!check) {
    console.log(`Updated generated files: ${mismatches.join(", ")}`);
  }
}

function validateManifestData(data) {
  if (!data || typeof data !== "object" || !data.builds || typeof data.builds !== "object") {
    throw new Error("Manifest must contain a builds object.");
  }

  const cacheScopes = new Set();
  const errors = [];
  const values = manifestValues(data);
  const defaults = manualDefaults(data, values);
  const scheduleDefaults = scheduledDefaults(data, values);

  if (!values.repos.includes(defaults.repo)) {
    errors.push(`workflow.manual.default_repo must be one of: ${values.repos.join(", ")}`);
  }
  if (!values.devices.includes(defaults.device)) {
    errors.push(`workflow.manual.default_device must be one of: ${values.devices.join(", ")}`);
  }
  if (!values.flavors.includes(defaults.flavor)) {
    errors.push(`workflow.manual.default_flavor must be one of: ${values.flavors.join(", ")}`);
  }
  if (!values.repos.includes(scheduleDefaults.repo)) {
    errors.push(`workflow.schedule.default_repo must be one of: ${values.repos.join(", ")}`);
  }
  for (const device of parseSelection(scheduleDefaults.devices, "workflow.schedule.default_devices")) {
    if (!values.devices.includes(device)) {
      errors.push(`workflow.schedule.default_devices contains unknown device '${device}'`);
    }
  }
  for (const flavor of parseSelection(scheduleDefaults.flavors, "workflow.schedule.default_flavors")) {
    if (!values.flavors.includes(flavor)) {
      errors.push(`workflow.schedule.default_flavors contains unknown flavor '${flavor}'`);
    }
  }

  for (const [repo, repoData] of Object.entries(data.builds)) {
    if (!repoData.branch) {
      errors.push(`${repo}: missing branch`);
    }
    if (!repoData.url) {
      errors.push(`${repo}: missing url`);
    }
    if (!Array.isArray(repoData.devices) || repoData.devices.length === 0) {
      errors.push(`${repo}: devices must be a non-empty array`);
      continue;
    }

    for (const item of repoData.devices) {
      const label = `${repo}/${item.id || "unknown"}`;
      for (const field of ["id", "op_name", "flavor", "target_config", "app_config", "cache_scope"]) {
        if (!item[field]) {
          errors.push(`${label}: missing ${field}`);
        }
      }

      if (item.cache_scope) {
        if (cacheScopes.has(item.cache_scope)) {
          errors.push(`${label}: duplicate cache_scope ${item.cache_scope}`);
        }
        cacheScopes.add(item.cache_scope);
      }

      for (const field of ["target_config", "app_config", "driver_config"]) {
        if (item[field] && !existsSync(resolve(rootDir, item[field]))) {
          errors.push(`${label}: ${field} not found: ${item[field]}`);
        }
      }
    }
  }

  if (errors.length > 0) {
    throw new Error(`Manifest validation failed:\n- ${errors.join("\n- ")}`);
  }
}

function validateManifest(args) {
  const { data } = readManifest(args.manifest);
  validateManifestData(data);
  console.log("Manifest validation passed.");
}

function repoUrl(args) {
  const { data } = readManifest(args.manifest);
  const repo = args.repo || "";
  const url = data.builds?.[repo]?.url;

  if (!url) {
    throw new Error(`Unknown repo or missing url: ${repo}`);
  }

  console.log(url);
}

function main() {
  const [command, ...rest] = process.argv.slice(2);
  const args = parseArgs(rest);

  try {
    switch (command) {
      case "resolve-matrix":
        resolveMatrix(args);
        break;
      case "validate-manifest":
        validateManifest(args);
        break;
      case "generate-workflows":
        generateWorkflows(args);
        break;
      case "repo-url":
        repoUrl(args);
        break;
      default:
        usage();
        process.exitCode = 2;
    }
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}

main();
