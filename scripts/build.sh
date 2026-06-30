#!/usr/bin/env bash
set -euo pipefail

OPENWRT_DIR="${OPENWRT_DIR:-openwrt}"
PHASE="${1:-all}"
JOBS="${JOBS:-$(nproc)}"
FALLBACK_JOBS="${FALLBACK_JOBS:-4}"

cd "$OPENWRT_DIR"

download_sources() {
  make download -j"$JOBS"
  find dl -size -1024c -exec ls -l {} \;
  find dl -size -1024c -exec rm -f {} \;
}

run_make() {
  local label="${1:-world}"

  echo "$JOBS thread compile: $label"
  if [ "$#" -eq 0 ]; then
    make -j"$JOBS" V=s || make -j"$FALLBACK_JOBS" V=s
  else
    make -j"$JOBS" "$@" V=s || make -j"$FALLBACK_JOBS" "$@" V=s
  fi
}

case "$PHASE" in
  download)
    download_sources
    ;;
  tools)
    run_make tools/install
    ;;
  toolchain)
    run_make toolchain/install
    ;;
  target)
    run_make target/compile
    ;;
  packages)
    run_make package/compile
    ;;
  images)
    run_make package/install
    run_make target/install
    run_make package/index
    ;;
  all)
    download_sources
    run_make
    ;;
  *)
    echo "Unknown build phase: $PHASE" >&2
    echo "Usage: $0 [download|tools|toolchain|target|packages|images|all]" >&2
    exit 1
    ;;
esac
