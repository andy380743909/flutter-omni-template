#!/usr/bin/env bash
#
# bootstrap.sh — Generate the native platform directories for the 6 official
# Flutter platforms and print guidance for HarmonyOS (Flutter-OH).
#
# This script does NOT create the hundreds of native files by hand; it delegates
# to `flutter create`, exactly as a developer would. Run it once after cloning
# the template (and whenever you add a new platform).
#
set -euo pipefail

# Resolve the project root (parent of the directory containing this script).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Project root: $ROOT_DIR"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: 'flutter' was not found on your PATH." >&2
  echo "       Install the Flutter SDK (stable channel) before running this script." >&2
  exit 1
fi

echo "==> Fetching Dart/Flutter dependencies (flutter pub get)..."
flutter pub get

echo "==> Generating native platform directories for the 6 official platforms..."
echo "    (ios, android, windows, macos, linux, web)"
flutter create --platforms=ios,android,windows,macos,linux,web .

echo ""
echo "==================================================================="
echo "  HarmonyOS (Flutter-OH) is NOT part of the official Flutter create."
echo "  It requires the HarmonyOS-adapted Flutter SDK (Flutter-OH)."
echo ""
echo "  To add the ohos platform on a machine WITH the Flutter-OH SDK:"
echo "    1. Put the Flutter-OH 'flutter' on your PATH."
echo "    2. flutter create --platforms=ohos ."
echo "    3. flutter build hap --release"
echo ""
echo "  Signing / AppGallery Connect upload steps: see docs/CI-CD.md"
echo "==================================================================="
echo ""

echo "==> Bootstrap complete. Suggested next steps:"
echo "    flutter run            # run the app on a connected device/emulator"
echo "    flutter test           # run unit + widget tests"
echo "    flutter test integration_test   # run end-to-end integration tests"
echo "    See README.md for the full guide."
