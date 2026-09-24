#!/usr/bin/env bash
#
# ohos_sign.sh — Wire HarmonyOS AGC signing material into ohos/build-profile.json5
# so that `flutter build hap` produces a SIGNED .hap ready to install on a device
# or the DevEco simulator.
#
# The script keeps NO secrets. All material paths/passwords come from the
# environment, so it is safe to commit. After running it, rebuild with:
#     source scripts/ohos-env.sh && flutter build hap
#
# Prerequisites — signing material from AppGallery Connect (AGC) or DevEco
# auto-sign (File → Project Structure → Signing Configs → Automatically generate):
#   * .p12  (keystore)
#   * .cer  (signing certificate)
#   * .p7b  (provisioning profile, tied to your device UDID for real devices)
#
# Usage (env-driven):
#   SIGN_P12=/abs/path/app.p12 \
#   SIGN_CER=/abs/path/app.cer \
#   SIGN_P7B=/abs/path/app.p7b \
#   SIGN_ALIAS=keyAlias \
#   SIGN_STORE_PWD='...' \
#   SIGN_KEY_PWD='...' \
#   ./scripts/ohos_sign.sh
#
# Optional: set OHOS_PROFILE=/abs/path/to/ohos to point at a different project root.
set -euo pipefail

ROOT_DIR="${OHOS_PROFILE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROFILE="$ROOT_DIR/ohos/build-profile.json5"

# ---- Read inputs from env (no defaults that would silently break the build) ----
SIGN_P12="${SIGN_P12:-}"
SIGN_CER="${SIGN_CER:-}"
SIGN_P7B="${SIGN_P7B:-}"
SIGN_ALIAS="${SIGN_ALIAS:-}"
SIGN_STORE_PWD="${SIGN_STORE_PWD:-}"
SIGN_KEY_PWD="${SIGN_KEY_PWD:-}"

missing=()
[ -z "$SIGN_P12" ]        && missing+=("SIGN_P12")
[ -z "$SIGN_CER" ]        && missing+=("SIGN_CER")
[ -z "$SIGN_P7B" ]        && missing+=("SIGN_P7B")
[ -z "$SIGN_ALIAS" ]      && missing+=("SIGN_ALIAS")
[ -z "$SIGN_STORE_PWD" ]  && missing+=("SIGN_STORE_PWD")
[ -z "$SIGN_KEY_PWD" ]    && missing+=("SIGN_KEY_PWD")

if [ "${#missing[@]}" -gt 0 ]; then
  echo "ERROR: missing required env vars: ${missing[*]}" >&2
  echo "       See header comments for usage." >&2
  exit 1
fi

# Validate that the material files actually exist.
for f in "$SIGN_P12" "$SIGN_CER" "$SIGN_P7B"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: signing material not found: $f" >&2
    exit 1
  fi
done

if [ ! -f "$PROFILE" ]; then
  echo "ERROR: build-profile.json5 not found at: $PROFILE" >&2
  exit 1
fi

# Backup before mutating.
BACKUP="${PROFILE}.bak.$(date +%Y%m%d%H%M%S)"
cp "$PROFILE" "$BACKUP"
echo "==> Backed up build-profile.json5 → $BACKUP"

# Inject the signingConfigs block. build-profile.json5 is JSON5 (may contain
# comments), so we do a targeted string replacement of the empty array rather
# than a full JSON parse.
python3 - "$PROFILE" <<PY
import sys, io

path = sys.argv[1]
with io.open(path, 'r', encoding='utf-8') as fh:
    content = fh.read()

# Absolute, shell-expanded paths so hvigor can find the material regardless of CWD.
import os
p12  = os.path.abspath("${SIGN_P12}")
cer  = os.path.abspath("${SIGN_CER}")
p7b  = os.path.abspath("${SIGN_P7B}")
alias = "${SIGN_ALIAS}"
store_pwd = "${SIGN_STORE_PWD}"
key_pwd   = "${SIGN_KEY_PWD}"

block = (
    '"signingConfigs": [\n'
    '      {\n'
    '        "name": "default",\n'
    '        "type": "HarmonyOS",\n'
    '        "material": {\n'
    '          "certpath": "' + cer + '",\n'
    '          "storePassword": "' + store_pwd + '",\n'
    '          "keyAlias": "' + alias + '",\n'
    '          "keyPassword": "' + key_pwd + '",\n'
    '          "profile": "' + p7b + '",\n'
    '          "signAlg": "SHA256withECDSA",\n'
    '          "storeFile": "' + p12 + '"\n'
    '        }\n'
    '      }\n'
    '    ]'
)

marker = '"signingConfigs": []'
if marker not in content:
    # Already configured? Refuse to clobber an existing config silently.
    if '"signingConfigs": [' in content:
        print("WARN: signingConfigs already present; left untouched. "
              "Edit build-profile.json5 manually or restore the .bak backup.", file=sys.stderr)
        sys.exit(0)
    else:
        print("ERROR: could not find signingConfigs marker in build-profile.json5", file=sys.stderr)
        sys.exit(1)

content = content.replace(marker, block, 1)
with io.open(path, 'w', encoding='utf-8') as fh:
    fh.write(content)
print("==> Injected 'default' signingConfig into build-profile.json5")
PY

echo "==> Done. Next: source scripts/ohos-env.sh && flutter build hap"
echo "    Signed HAP: ohos/entry/build/default/outputs/default/entry-default-signed.hap"
echo "    Install:    hdc install -r ohos/entry/build/default/outputs/default/entry-default-signed.hap"
