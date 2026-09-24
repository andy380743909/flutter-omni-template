#!/usr/bin/env bash
# ============================================================
# OpenHarmony / HarmonyOS Flutter 工具链环境加载脚本
# 用法: source scripts/ohos-env.sh
# 仅设置环境变量，不执行任何构建；与现有 iOS 用的标准 flutter 完全隔离。
# ============================================================

# --- 1. Flutter-OH (OpenHarmony 社区版 Flutter，独立安装，不碰 /Users/andy/flutter-sdk) ---
export FLUTTER_OHOS_ROOT="/Users/andy/flutter-ohos"
export PATH="$FLUTTER_OHOS_ROOT/bin:$PATH"

# --- 2. OpenHarmony SDK (来自已下载的 HarmonyOS command-line-tools) ---
export OHOS_SDK_HOME="/Users/andy/Projects/command-line-tools/sdk/default/openharmony"

# --- 3. 工具链: ohpm / hvigorw / hdc ---
export PATH="/Users/andy/Projects/command-line-tools/bin:$PATH"
# hdc 位于版本化目录的 toolchains 下（default/26/toolchains/hdc，26 是指向 openharmony 的软链层）
export PATH="/Users/andy/Projects/command-line-tools/sdk/default/26/toolchains:$PATH"

# --- 4. Node (hvigorw 需要) ---
if [ -d "/Users/andy/Projects/command-line-tools/tool/node" ]; then
  export DEVECO_NODE_HOME="/Users/andy/Projects/command-line-tools/tool/node"
else
  # 退回系统/受管 node
  _sys_node="$(command -v node 2>/dev/null)"
  if [ -n "$_sys_node" ]; then
    export DEVECO_NODE_HOME="$(dirname "$(dirname "$_sys_node")")"
  fi
fi
if [ -n "$DEVECO_NODE_HOME" ] && [ -d "$DEVECO_NODE_HOME/bin" ]; then
  export PATH="$DEVECO_NODE_HOME/bin:$PATH"
fi

# --- 5. Java 17 (Deveco / Hvigor 需要) ---
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

echo "[ohos-env] FLUTTER_OHOS_ROOT = $FLUTTER_OHOS_ROOT"
echo "[ohos-env] OHOS_SDK_HOME    = $OHOS_SDK_HOME"
echo "[ohos-env] DEVECO_NODE_HOME = ${DEVECO_NODE_HOME:-<none>}"
echo "[ohos-env] which flutter    = $(command -v flutter)"
