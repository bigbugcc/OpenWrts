#!/usr/bin/env python3
import argparse
import datetime as dt
import json
import os
from pathlib import Path


def resolve_repo(requested: str) -> str:
    if requested != "auto":
        return requested

    week = dt.datetime.now(dt.UTC).isocalendar().week
    return "lede" if week % 2 == 0 else "immortalwrt"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", default="manifests/builds.json")
    parser.add_argument("--repo", default="auto")
    parser.add_argument("--device", default="all")
    parser.add_argument("--flavor", default="all")
    parser.add_argument("--branch", default="")
    args = parser.parse_args()

    repo = resolve_repo(args.repo)
    manifest_path = Path(args.manifest)
    data = json.loads(manifest_path.read_text(encoding="utf-8"))

    if repo not in data["builds"]:
        raise SystemExit(f"Unknown repo '{repo}'.")

    repo_data = data["builds"][repo]
    branch = args.branch or repo_data.get("branch", "master")
    include = []

    for item in repo_data.get("devices", []):
        if args.device != "all" and item["id"] != args.device:
            continue
        if args.flavor != "all" and item.get("flavor", "") != args.flavor:
            continue

        matrix_item = dict(item)
        matrix_item["repo"] = repo
        matrix_item["branch"] = branch
        include.append(matrix_item)

    if not include:
        raise SystemExit(
            f"No builds matched repo={repo}, device={args.device}, flavor={args.flavor}."
        )

    output = {
        "repo": repo,
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
