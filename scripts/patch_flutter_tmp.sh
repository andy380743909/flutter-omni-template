#!/usr/bin/env bash
# Idempotent re-apply: redirect Flutter's engine.stamp.tmp out of the SDK cache
# into $TMPDIR, so interrupted `flutter` runs no longer leave a pid-suffixed stray
# file (engine.stamp.tmp.<pid>) in ~/flutter-sdk/bin/cache that triggers a
# per-build delete authorization.
#
# Why this exists: `flutter upgrade` overwrites
# bin/internal/update_engine_version.sh. If builds start asking you to delete
# engine.stamp.tmp.<pid> again, just run:  bash scripts/patch_flutter_tmp.sh
#
# Override the SDK path with FLUTTER_SDK=/path/to/flutter if it moves.
set -e

FLUTTER_ROOT="${FLUTTER_SDK:-/Users/andy/flutter-sdk}"
TARGET="$FLUTTER_ROOT/bin/internal/update_engine_version.sh"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: $TARGET not found. Set FLUTTER_SDK=/path/to/flutter." >&2
  exit 1
fi

python3 - "$TARGET" <<'PY'
import sys
p = sys.argv[1]
src = open(p, encoding='utf-8').read()
old = '''pid=$$
es_tmp="$FLUTTER_ROOT/bin/cache/engine.stamp.tmp.$pid"
trap 'rm -f "$es_tmp"' EXIT
echo "$ENGINE_VERSION" >"$es_tmp" && mv "$es_tmp" "$FLUTTER_ROOT/bin/cache/engine.stamp"
trap - EXIT'''
new = '''pid=$$
# Write the transient tmp in the system temp dir ($TMPDIR, fallback /tmp) instead of
# inside $FLUTTER_ROOT/bin/cache. Interrupted flutter runs previously left a
# pid-suffixed stray file (engine.stamp.tmp.<pid>) in the SDK cache, which forced a
# per-build delete authorization. The final stamp still lands in the cache where
# flutter expects it; only the transient tmp moves out of the SDK.
_es_tmp_dir="${TMPDIR:-/tmp}"
es_tmp="$_es_tmp_dir/flutter_engine_stamp.tmp.$pid"
trap 'rm -f "$es_tmp"' EXIT
echo "$ENGINE_VERSION" >"$es_tmp" && mv "$es_tmp" "$FLUTTER_ROOT/bin/cache/engine.stamp"
trap - EXIT'''
if old in src:
    open(p, 'w', encoding='utf-8').write(src.replace(old, new))
    print("patched: engine.stamp.tmp redirected to $TMPDIR")
elif new in src:
    print("already patched: no change needed")
else:
    print("ERROR: expected block not found; SDK script may have changed.", file=sys.stderr)
    sys.exit(2)
PY

echo "done: $TARGET"
