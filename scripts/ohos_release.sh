#!/usr/bin/env bash
#
# ohos_release.sh — Build a HarmonyOS .hap via Flutter-OH and upload it to
# AppGallery Connect (AGC) using the AGC REST API.
#
# Prerequisites:
#   - The Flutter-OH SDK's `flutter` must be on PATH (NOT upstream Flutter).
#   - hvigorw (DevEco build tool) available via the Flutter-OH toolchain.
#   - AGC API credentials (see placeholders below). Create them in
#     AppGallery Connect > Users and Permissions > API Key Management.
#
# Usage:
#   AGC_CLIENT_ID=xxx AGC_CLIENT_SECRET=yyy APP_ID=zzz ./scripts/ohos_release.sh
#   (or export them / put them in a local, git-ignored .env file)
#
set -euo pipefail

# ---- Configurable (override via env or edit here) ----------------------------
AGC_AUTH_URL="${AGC_AUTH_URL:-https://oauth-login.cloud.huawei.com/oauth2/v3/token}"
AGC_API_URL="${AGC_API_URL:-https://connect-api.cloud.huawei.com/api}"
CLIENT_ID="${AGC_CLIENT_ID:-REPLACE_ME}"
CLIENT_SECRET="${AGC_CLIENT_SECRET:-REPLACE_ME}"
APP_ID="${APP_ID:-REPLACE_ME}"
HAP_PATH="${HAP_PATH:-build/harmonyos/entry/default/entry-default-signed.hap}"
RELEASE_TYPE="${RELEASE_TYPE:-1}"   # 1 = 非正式(测试), 3 = 正式发布
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

echo "==> [ohos] Project root: $ROOT_DIR"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: 'flutter' not found. Use the Flutter-OH SDK (not upstream Flutter)." >&2
  exit 1
fi

echo "==> [ohos] Resolving dependencies..."
flutter pub get

echo "==> [ohos] Building release .hap..."
flutter build hap --release

if [ ! -f "$HAP_PATH" ]; then
  echo "ERROR: Built .hap not found at $HAP_PATH" >&2
  echo "       Adjust HAP_PATH to match your Flutter-OH output." >&2
  exit 1
fi

if [ "$CLIENT_ID" = "REPLACE_ME" ] || [ "$CLIENT_SECRET" = "REPLACE_ME" ]; then
  echo "WARN: AGC credentials not set; skipping upload." >&2
  echo "      Set AGC_CLIENT_ID / AGC_CLIENT_SECRET / APP_ID and rerun to upload." >&2
  exit 0
fi

echo "==> [ohos] Requesting AGC access token..."
ACCESS_TOKEN="$(curl -s -X POST "$AGC_AUTH_URL" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d "grant_type=client_credentials" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  | python3 -c 'import sys, json; print(json.load(sys.stdin).get("access_token", ""))')"

if [ -z "$ACCESS_TOKEN" ]; then
  echo "ERROR: Failed to obtain AGC access token." >&2
  exit 1
fi

echo "==> [ohos] Uploading $HAP_PATH to AppGallery Connect..."
# AGC requires a multipart upload of the .hap followed by a submit call. Endpoint
# paths follow the v2 publishing API and may differ by AGC version — adjust to
# match your AppGallery Connect API reference.
UPLOAD_URL="$AGC_API_URL/v2/app/uploadFile?appId=$APP_ID"
curl -s -X POST "$UPLOAD_URL" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "file=@$HAP_PATH;type=application/zip"

echo "==> [ohos] Submitting for release (type=$RELEASE_TYPE)..."
SUBMIT_URL="$AGC_API_URL/v2/app/uploadFile/submit?appId=$APP_ID&releaseType=$RELEASE_TYPE"
curl -s -X POST "$SUBMIT_URL" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"fileType":2}'

echo "==> [ohos] Done. Verify the submission in AppGallery Connect."
