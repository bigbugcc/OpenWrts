#!/usr/bin/env python3
import argparse
import datetime as dt
import json
import os
from pathlib import Path


def scheduled_repo() -> str:
    week = dt.datetime.now(dt.timezone.utc).isocalendar().week
    return "lede" if week % 2 == 0 else "immortalwrt"


def matching_items(data: dict, repo_names: list[str], device: str, flavor: str) -> list[dict]:
    include = []

    for repo in repo_names:
        repo_data = data["builds"][repo]
        for item in repo_data.get("devices", []):
            if device != "all" and item["id"] != device:
                continue
            if flavor != "all" and item.get("flavor", "") != flavor:
                continue

            matrix_item = dict(item)
            matrix_item["repo"] = repo
            include.append(matrix_item)

    return include


def available_matches(data: dict, device: str, flavor: str) -> str:
    matches = matching_items(data, list(data["builds"].keys()), device, flavor)
    if not matches:
        return "none"

    return ", ".join(
        f"{item['repo']}/{item['id']}[{item.get('flavor', 'unknown')}]"
        for item in matches
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", default="manifests/builds.json")
    parser.add_argument("--repo", default="auto")
    parser.add_argument("--device", default="all")
    parser.add_argument("--flavor", default="all")
    parser.add_argument("--branch", default="")
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    data = json.loads(manifest_path.read_text(encoding="utf-8"))

    if args.repo != "auto" and args.repo not in data["builds"]:
        raise SystemExit(f"Unknown repo '{args.repo}'.")

    if args.repo == "auto" and args.device != "all":
        repo_names = list(data["builds"].keys())
        repo = "auto"
    else:
        repo = scheduled_repo() if args.repo == "auto" else args.repo
        repo_names = [repo]

    include = matching_items(data, repo_names, args.device, args.flavor)

    for item in include:
        repo_data = data["builds"][item["repo"]]
        item["branch"] = args.branch or repo_data.get("branch", "master")

    if not include:
        alternatives = available_matches(data, args.device, args.flavor)
        raise SystemExit(
            "No builds matched "
            f"repo={args.repo}, device={args.device}, flavor={args.flavor}. "
            f"Available matching builds: {alternatives}."
        )

    output_repo = include[0]["repo"] if len({item["repo"] for item in include}) == 1 else "multiple"
    output = {
        "repo": output_repo,
        "matrix": json.dumps({"include": include}, separators=(",", ":")),
    }

    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a", encoding="utf-8") as fh:
            for key, value in output.items():
                fh.write(f"{key}={value}\n")
    else:
        print(json.dumps(output, indent=2))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
