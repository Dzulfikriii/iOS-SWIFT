#!/usr/bin/env bash
set -euo pipefail

# Rebuilds the app for iOS Simulator, reinstalls it, and relaunches it.
# Defaults:
#   Project: test.xcodeproj
#   Scheme:  test
#   Config:  Debug
#   Device:  iPhone 17 Pro (change with --device "..." or DEVICE_NAME env)
#   DerivedData: ./build
# Usage examples:
#   scripts/run-ios-sim.sh
#   scripts/run-ios-sim.sh --device "iPhone 17 Pro Max"
#   DEVICE_NAME="iPhone 17" scripts/run-ios-sim.sh
#   scripts/run-ios-sim.sh --clean

PROJECT="test.xcodeproj"
SCHEME="test"
CONFIG="Debug"
DERIVED="$(pwd)/build"
SIM_DEVICE="${DEVICE_NAME:-iPhone 17 Pro}"
CLEAN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT="$2"; shift 2;;
    --scheme)
      SCHEME="$2"; shift 2;;
    --config)
      CONFIG="$2"; shift 2;;
    --device)
      SIM_DEVICE="$2"; shift 2;;
    --derivedDataPath)
      DERIVED="$2"; shift 2;;
    --clean)
      CLEAN="true"; shift 1;;
    *)
      echo "Unknown option: $1" >&2; exit 1;;
  esac
done

APP_PATH="$DERIVED/Build/Products/${CONFIG}-iphonesimulator/${SCHEME}.app"

function info() { echo "[run-ios-sim] $*"; }

info "Opening Simulator app..."
open -a Simulator || true

info "Booting device: $SIM_DEVICE"
xcrun simctl boot "$SIM_DEVICE" || true

if [[ "$CLEAN" == "true" ]]; then
  info "Cleaning build..."
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIG" -sdk iphonesimulator -destination "platform=iOS Simulator,name=$SIM_DEVICE" -derivedDataPath "$DERIVED" clean || true
fi

info "Building ($CONFIG) for $SIM_DEVICE..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIG" -sdk iphonesimulator -destination "platform=iOS Simulator,name=$SIM_DEVICE" -derivedDataPath "$DERIVED" build

if [[ ! -d "$APP_PATH" ]]; then
  echo "App bundle not found at: $APP_PATH" >&2
  exit 2
fi

info "Installing app..."
xcrun simctl install booted "$APP_PATH"

info "Resolving bundle identifier..."
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP_PATH/Info.plist")
info "Bundle ID: $BUNDLE_ID"

info "Terminating any running instance..."
xcrun simctl terminate booted "$BUNDLE_ID" || true

info "Launching app..."
xcrun simctl launch booted "$BUNDLE_ID"

info "Done."