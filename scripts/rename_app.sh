#!/usr/bin/env bash
#
# rename_app.sh — Rebrand a fresh copy of the app_template.
#
# USAGE:
#   ./scripts/rename_app.sh <new_dart_package> <new_bundle_id>
#
#   new_dart_package : Dart/Pub package name, lower_snake_case, e.g. my_new_app
#   new_bundle_id    : reverse-domain app id,        e.g. com.mycompany.myapp
#
# WHAT IT DOES:
#   1. Replace `package:app_template/` imports         -> `package:<new>/`
#   2. Replace `name: app_template` in pubspec.yaml    -> <new>
#   3. Replace native bundle ids com.example.app_template / com.example.appTemplate
#      -> <new_bundle_id> across android/ ios/ macos/ windows/ linux/ ohos/ + fastlane/
#
# WHAT YOU MUST DO MANUALLY (cannot be safely scripted):
#   - Android: move android/app/src/main/kotlin/com/example/app_template/
#     to .../kotlin/<your/package/path>/ and update the `package` line in
#     MainActivity.kt (and any other .kt files). Flutter tolerates the old
#     directory for local dev, but Google Play requires the path to match.
#   - Update applicationId / display name / icons per platform as needed.
#
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <new_dart_package> <new_bundle_id>" >&2
  echo "  e.g. $0 my_new_app com.mycompany.myapp" >&2
  exit 1
fi

NEW_PKG="$1"
NEW_BUNDLE="$2"
OLD_PKG="app_template"
OLD_BUNDLE_A="com.example.app_template"
OLD_BUNDLE_B="com.example.appTemplate"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# Portable `sed -i`: GNU sed (Linux) uses `-i`, BSD sed (macOS) needs `-i ''`.
if sed --version >/dev/null 2>&1; then SED_I=("-i"); else SED_I=("-i" ""); fi

echo "==> Rebranding app_template -> dart:$NEW_PKG / bundle:$NEW_BUNDLE"

echo "==> 1/3 Renaming Dart package & imports..."
sed "${SED_I[@]}" "s/package:$OLD_PKG\//package:$NEW_PKG\//g" \
  $(grep -rl "package:$OLD_PKG/" lib test test_features integration_test 2>/dev/null)
sed "${SED_I[@]}" "s/^name: $OLD_PKG/name: $NEW_PKG/" pubspec.yaml

echo "==> 2/3 Renaming native bundle identifiers..."
# Collect files that mention either form of the old bundle id.
FILES=$(grep -rl -e "$OLD_BUNDLE_A" -e "$OLD_BUNDLE_B" \
  android ios macos windows linux ohos fastlane 2>/dev/null || true)
for f in $FILES; do
  sed "${SED_I[@]}" -e "s/$OLD_BUNDLE_A/$NEW_BUNDLE/g" -e "s/$OLD_BUNDLE_B/$NEW_BUNDLE/g" "$f"
done

echo "==> 3/3 Done. REMEMBER the manual steps:"
echo "   1. Move android/app/src/main/kotlin/com/example/app_template/ to match $NEW_BUNDLE"
echo "   2. Update the Kotlin 'package' declaration in MainActivity.kt"
echo "   3. flutter pub get && flutter analyze"
echo "   Verify with: grep -rn 'app_template' android ios macos windows linux ohos fastlane"
