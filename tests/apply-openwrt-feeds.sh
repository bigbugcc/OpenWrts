#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/apply-openwrt.sh"
WORK_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

active_feed_count() {
  awk '$1 ~ /^src-/ { count += 1 } END { print count + 0 }' "$1"
}

collect_configured_feeds() {
  local feed_file

  for feed_file in "$@"; do
    [ -f "$feed_file" ] || continue
    awk '
      /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
      $1 ~ /^src-[^[:space:]]+$/ && NF >= 3 { print }
    ' "$feed_file"
  done
}

normalize_feed_source() {
  local feed_source="$1"

  feed_source="${feed_source%%;*}"
  while [[ "$feed_source" == */ ]]; do
    feed_source="${feed_source%/}"
  done
  feed_source="${feed_source%.git}"
  printf '%s\n' "$feed_source"
}

expected_unique_count() {
  local feed_line
  local feed_type
  local feed_name
  local feed_source
  local normalized_source
  local expected=0
  local -A seen_names=()
  local -A seen_sources=()

  for feed_line in "$@"; do
    read -r feed_type feed_name feed_source _ <<< "$feed_line"
    normalized_source="$(normalize_feed_source "$feed_source")"
    if [[ -n "${seen_names[$feed_name]+configured}" || -n "${seen_sources[$normalized_source]+configured}" ]]; then
      continue
    fi
    seen_names["$feed_name"]=1
    seen_sources["$normalized_source"]=1
    expected=$((expected + 1))
  done

  printf '%s\n' "$expected"
}

assert_feed_present() {
  local file="$1"
  local feed_name="$2"
  local feed_source="$3"

  if ! awk -v wanted_name="$feed_name" -v wanted_source="$feed_source" '
    function normalize_source(source) {
      sub(/;.*/, "", source)
      sub(/\/+$/, "", source)
      sub(/\.git$/, "", source)
      return source
    }

    /^[[:space:]]*#/ { next }
    $1 ~ /^src-[^[:space:]]+$/ && NF >= 3 {
      if ($2 == wanted_name || normalize_source($3) == normalize_source(wanted_source)) {
        found = 1
        exit
      }
    }

    END { exit !found }
  ' "$file"; then
    echo "Feed is not represented in $file: name=$feed_name source=$feed_source" >&2
    exit 1
  fi
}

assert_no_duplicate_feeds() {
  local file="$1"

  if ! awk '
    function normalize_source(source) {
      sub(/;.*/, "", source)
      sub(/\/+$/, "", source)
      sub(/\.git$/, "", source)
      return source
    }

    /^[[:space:]]*#/ { next }
    $1 ~ /^src-[^[:space:]]+$/ && NF >= 3 {
      source = normalize_source($3)
      if (seen_name[$2]++ || seen_source[source]++) {
        exit 1
      }
    }
  ' "$file"; then
    echo "Duplicate feed name or source found in $file" >&2
    exit 1
  fi
}

test_repo_feeds() {
  local repo="$1"
  local repo_work_dir="$WORK_DIR/$repo"
  local target_feeds="$repo_work_dir/feeds.conf.default"
  local snapshot="$repo_work_dir/feeds.after-first-apply"
  local expected_count
  local actual_count
  local feed_line
  local feed_type
  local feed_name
  local feed_source
  local feed_index=0
  local feed_files=("$ROOT_DIR/feeds/common.conf")
  local configured_feeds=()

  if [ -f "$ROOT_DIR/feeds/$repo.conf" ]; then
    feed_files+=("$ROOT_DIR/feeds/$repo.conf")
  fi
  mapfile -t configured_feeds < <(collect_configured_feeds "${feed_files[@]}")
  if [ "${#configured_feeds[@]}" -eq 0 ]; then
    echo "Expected at least one configured feed for REPO=$repo." >&2
    exit 1
  fi

  mkdir -p "$repo_work_dir"
  : > "$target_feeds"

  REPO="$repo" bash "$SCRIPT" --openwrt-dir "$repo_work_dir" feeds

  expected_count="$(expected_unique_count "${configured_feeds[@]}")"
  actual_count="$(active_feed_count "$target_feeds")"
  if [ "$actual_count" != "$expected_count" ]; then
    echo "Expected $expected_count feeds for REPO=$repo after first apply, got $actual_count." >&2
    exit 1
  fi
  assert_no_duplicate_feeds "$target_feeds"
  for feed_line in "${configured_feeds[@]}"; do
    read -r feed_type feed_name feed_source _ <<< "$feed_line"
    assert_feed_present "$target_feeds" "$feed_name" "$feed_source"
  done

  cp "$target_feeds" "$snapshot"
  REPO="$repo" bash "$SCRIPT" --openwrt-dir "$repo_work_dir" feeds
  if ! cmp -s "$snapshot" "$target_feeds"; then
    echo "Feed application is not idempotent for REPO=$repo." >&2
    exit 1
  fi

  # Alternate between an upstream name match and a source URL match for every
  # configured entry. Applying the overlays must leave this file unchanged.
  : > "$target_feeds"
  for feed_line in "${configured_feeds[@]}"; do
    read -r feed_type feed_name feed_source _ <<< "$feed_line"
    if [ $((feed_index % 2)) -eq 0 ]; then
      printf '%s %s https://existing.invalid/%s/%s.git\n' \
        "$feed_type" "$feed_name" "$repo" "$feed_index" >> "$target_feeds"
    else
      printf '%s existing-%s-%s %s\n' \
        "$feed_type" "$repo" "$feed_index" "$feed_source" >> "$target_feeds"
    fi
    feed_index=$((feed_index + 1))
  done

  cp "$target_feeds" "$snapshot"
  REPO="$repo" bash "$SCRIPT" --openwrt-dir "$repo_work_dir" feeds
  if ! cmp -s "$snapshot" "$target_feeds"; then
    echo "Existing upstream feeds were unexpectedly modified for REPO=$repo." >&2
    exit 1
  fi
}

REPOS=()
for package_script in "$ROOT_DIR"/packages/*.sh; do
  [ -f "$package_script" ] || continue
  repo="$(basename "$package_script" .sh)"
  REPOS+=("$repo")
done

if [ "${#REPOS[@]}" -eq 0 ]; then
  echo "No source repositories found in packages/." >&2
  exit 1
fi

for repo in "${REPOS[@]}"; do
  test_repo_feeds "$repo"
done

echo "apply-openwrt feed de-duplication tests passed for: ${REPOS[*]}"
