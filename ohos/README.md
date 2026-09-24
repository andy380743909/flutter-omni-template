# HarmonyOS (鸿蒙) 平台配置 — 模板占位

> 鸿蒙 **不在** 官方 Flutter 之内。本目录下的配置文件是 **模板占位**，用于在装有
> [Flutter-OH](https://gitcode.com/openharmony-sig/flutter_flutter) SDK 的机器上，由
> `flutter create --platforms=ohos .` 生成 / 覆盖之后，作为**你填写应用信息的起点**。

## 本目录的文件来源与用途

| 文件 | 用途 | 是否需手工改 |
|------|------|--------------|
| `AppScope/app.json5` | 应用级配置：`bundleName`、版本、`icon`/`label` 引用 | **是**（替换 `com.example.app_template` 为你的包名） |
| `build-profile.json5` | 工程级构建与**签名配置**（`signingConfigs`） | **是**（填入 AGC 下载的签名材料路径） |
| `entry/src/main/module.json5` | 模块配置：abilities、权限（`requestPermissions`） | 按需（默认已加 `INTERNET`） |
| `entry/build-profile.json5` | 模块构建选项（release 混淆等） | 一般不用改 |
| `oh-package.json5` | 模块 npm 包描述 | 改 `name`/`version` 即可 |

## 生成与发布流程

```bash
# 1. 在装有 Flutter-OH 的机器上，把 Flutter-OH 的 flutter 放到 PATH
which flutter && flutter --version   # 应显示 OpenHarmony 适配版

# 2. 生成 / 覆盖 ohos 工程
flutter create --platforms=ohos .

# 3. 用 DevEco 打开 ohos/ 工程，按 AGC 的签名文件填好 build-profile.json5 的 signingConfigs
#    （storeFile / keyAlias / profileFile / certpath 等）

# 4. 构建并上传（脚本内含 AGC REST API 上传逻辑）
bash scripts/ohos_release.sh
#   或经 Fastlane：
bundle exec fastlane ohos release
```

## AGC 上传凭证（脚本 / Fastlane 用）

在 `scripts/ohos_release.sh` 或你的 CI Secret 中提供：

- `AGC_CLIENT_ID` / `AGC_CLIENT_SECRET`：AppGallery Connect → 用户与权限 → API 密钥管理
- `APP_ID`：AGC 应用 ID
- `HAP_PATH`：构建产物路径（默认 `build/harmonyos/entry/default/entry-default-signed.hap`，请以实际为准）

详见 `docs/CI-CD.md` 与 `docs/FASTLANE_RESEARCH.md`。
