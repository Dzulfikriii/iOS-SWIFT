#!/usr/bin/env bash
set -euo pipefail

# Watches source files and automatically rebuilds, reinstalls, and relaunches
# the iOS Simulator app when changes are detected — similar to `flutter run`.
#
# Defaults:
#   Device: iPhone 17 Pro (override with --device "..." or DEVICE_NAME env)
#   Debounce: 1s between change checks (--debounce N)
#   Paths: test/ testTests/ testUITests/
#
# Examples:
#   scripts/watch-ios-sim.sh
#   scripts/watch-ios-sim.sh --device "iPhone 17" --debounce 2
#   DEVICE_NAME="iPhone 17 Pro Max" scripts/watch-ios-sim.sh

SIM_DEVICE="${DEVICE_NAME:-iPhone 17 Pro}"
DEBOUNCE=1
WATCH_PATHS=("test" "testTests" "testUITests")

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      SIM_DEVICE="$2"; shift 2;;
    --debounce)
      DEBOUNCE="$2"; shift 2;;
    --path)
      WATCH_PATHS+=("$2"); shift 2;;
    *)
      echo "Unknown option: $1" >&2; exit 1;;
  esac
done

function info() { echo "[watch-ios-sim] $*"; }

function initial_run() {
  info "Initial build/install/launch on $SIM_DEVICE..."
  DEVICE_NAME="$SIM_DEVICE" scripts/run-ios-sim.sh
}

# Compute a hash signature of watched files (excluding build outputs)
function compute_signature() {
  # Collect files under watch paths, excluding common build artifacts.
  # Use md5 to produce a stable signature.
  local sig
  sig=$(find ${WATCH_PATHS[@]} \
    -type f \
    ! -path '*/build/*' \
    ! -path '*/.git/*' \
    ! -path '*/.DS_Store' \
    -exec md5 -q {} \; 2>/dev/null | sort | md5 -q)
  echo "$sig"
}

function rerun() {
  info "Change detected. Rebuilding and relaunching..."
  DEVICE_NAME="$SIM_DEVICE" scripts/run-ios-sim.sh || info "Run failed; will keep watching."
}

# Prefer fswatch if available for event-based watching; otherwise use polling.
if command -v fswatch >/dev/null 2>&1; then
  info "Using fswatch (event-based) with debounce ${DEBOUNCE}s"
  initial_run
  # -o / --one-per-batch: coalesce events, -d: debounce delay seconds
  fswatch -o -d "$DEBOUNCE" "${WATCH_PATHS[@]}" | while read -r _; do
    rerun
  done
else
  info "fswatch not found; using polling every ${DEBOUNCE}s"
  initial_run
  prev_sig="$(compute_signature || true)"
  while true; do
    sleep "$DEBOUNCE"
    cur_sig="$(compute_signature || true)"
    if [[ "${cur_sig:-}" != "${prev_sig:-}" ]]; then
      prev_sig="$cur_sig"
      rerun
    fi
  done
fi