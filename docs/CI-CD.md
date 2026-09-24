# CI / CD 流水线指南

> 配套：[FASTLANE_RESEARCH.md](./FASTLANE_RESEARCH.md)、`ARCHITECTURE.md` §11、`.github/workflows/*`、`fastlane/*`。

本模板把发布流程拆成**三段**，互不耦合、各司其职：

| 段 | 负责什么 | 在哪跑 | 工具 |
|----|----------|--------|------|
| ① PR 门禁 | 代码分析 / 格式化 / 单元+Widget 测试 / 覆盖率 / Web 编译校验 | Linux runner（快、便宜、紧贴代码） | GitHub Actions（`.github/workflows/ci.yml`） |
| ② 发布逻辑 | 版本号、打包、签名、上传商店、元数据 | 任意 runner（逻辑入仓、可本地复现） | Fastlane lanes（`fastlane/Fastfile`） |
| ③ 重发布（iOS） | 托管 macOS 签名（match/gym/deliver/pilot） | macOS runner 或 Codemagic | Fastlane + GitHub Actions（`.github/workflows/release.yml`） |

**心智模型**：Fastlane 是铺在水管最底层的"发布逻辑"，换 CI 厂商（GitHub Actions / Codemagic / Bitrise）时发布逻辑不丢。

---

## ① PR 门禁（`.github/workflows/ci.yml`）

每次 push 到 `main` 或开 PR 时触发，强制：

1. `dart format --set-exit-if-changed .`（格式不达标直接 fail）
2. `dart analyze`（0 warning 才过；`avoid_print` 设为 error）
3. `flutter test`（单元 + Widget，覆盖 `test/` 与 `test_features/`）
4. `flutter build web --release`（Web 编译校验）
5. 后续矩阵 job 对各平台做**仅编译**校验：Android APK、iOS（no-codesign）、Windows/macOS/Linux 原生构建

> 集成测试 / patrol（真机/模拟器）耗时长、需设备，**不放进每个 PR**，作为 release 前或 nightly 任务。

---

## ② 发布逻辑（Fastlane）

发布逻辑全部写在 `fastlane/Fastfile`，按平台分 lane：`android` / `ios` / `macos` / `windows` / `linux`，外加 `ohos` 占位 lane。

### 本地运行

```bash
bundle install                       # 安装 fastlane（见 Gemfile）
bundle exec fastlane android release # 打包 AAB 并上传 Play 内部轨道
bundle exec fastlane ios release     # match + gym + deliver + pilot
bundle exec fastlane macos release   # 打包 macOS，自行套 DMG
bundle exec fastlane windows release # 打包 Windows，自行套 InnoSetup/NSIS
bundle exec fastlane linux release   # 打包 Linux，自行套 AppImage
```

---

## ③ iOS 签名：如何 `fastlane match` 初始化

`match` 把证书/Provisioning Profile 存进**加密 git 仓库**，消除"换机器签名挂掉"的痛点。

1. **一次性（本地）**：
   ```bash
   bundle exec fastlane match init
   # 指向一个私有 git 仓库，例如 https://github.com/your-org/certs-repo.git
   bundle exec fastlane match appstore   # 生成/同步 App Store 证书与 profile
   ```
2. **CI 中只读同步**：`Fastfile` 里的 iOS lane 用 `match(type: "appstore", readonly: true)`。
3. **配置仓库 Secrets（切勿入库）**：
   - `MATCH_GIT_URL`
   - `MATCH_PASSWORD`（仓库解密密码）
   - `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`（Apple 专用密码）
   - `APPLE_ID`、`APPLE_TEAM_ID`

---

## Store 凭证配置

### Android（Play Console）

1. Play Console 创建 **Service Account**，下载 JSON 密钥。
2. 放到 `fastlane/play-key.json`（已在 `.gitignore`）或导出 `SUPPLY_JSON_KEY_FILE` 指向它。
3. `upload_to_play_store` 默认推到 `internal` 轨道。

### iOS（App Store / TestFlight）

- 通过 `match` 管理证书与 profile（见上）。
- `deliver` 上传二进制与元数据；`pilot` 管理 TestFlight 外部测试员。

### 桌面（macOS / Windows / Linux）

没有统一商店。lane 只产出原生构建物，分发方式自行选择：

- macOS：`create-dmg` 打包 `.app` → 官网下载 / Sparkle 更新。
- Windows：InnoSetup / NSIS 生成安装包。
- Linux：打包为 AppImage 或 deb/rpm。

---

## HarmonyOS（鸿蒙）发布步骤

> ⚠️ **版本分裂（重要）**：鸿蒙由 OpenHarmony SIG 社区用 `flutter_flutter` 分支单独维护，**版本号与官方 Flutter 不对应、且明显落后**。官方 Flutter 3.47.x 在鸿蒙上**不可用**。鸿蒙需另装独立的 Flutter-OH SDK，并钉到对应社区版本：
> - HarmonyOS NEXT 要求 **API 12（5.0.0(12)）及以上**。
> - 社区稳定版：`3.7.12-ohos`、`3.22.0-ohos`（HarmonyOS NEXT 推荐，支持 API 11/12+）、`3.27.4-ohos`。
> - 社区预览版到 `3.35.7dev` 左右，**尚无 3.47 对应版**。
> - 因此本模板 CI 钉的官方 `3.47.5` **不适用于鸿蒙**；鸿蒙链路请单独钉 `3.22.0-ohos` 之类，与官方 Flutter 是两套平行 SDK，需各自维护。

Fastlane **没有**鸿蒙插件，鸿蒙链路完全独立：

1. **准备环境**：安装 [Flutter-OH](https://gitcode.com/openharmony-sig/flutter_flutter)（鸿蒙适配版 Flutter）+ DevEco Studio。把 Flutter-OH 的 `flutter` 放到 `PATH`（注意这是**另一套** Flutter，与官方 3.47.5 并存，靠 `PATH` 切换）。
2. **生成 ohos 工程**（只需一次，且需 Flutter-OH 环境，不在官方 `flutter create` 之列）：
   ```bash
   flutter create --platforms=ohos .
   ```
3. **构建**（模板 `fastlane/Fastfile` 的 `ohos` lane 即封装此命令）：
   ```bash
   flutter build hap --release
   ```
4. **签名**：鸿蒙用 `.p12` 证书 + `SigningConfig`（`build-profile.json5`），通过 **AppGallery Connect（AGC）** 管理，与 Apple 体系不同。
5. **上传/分发**：通过 **AppGallery Connect API**（REST）或 `agconnect` CLI 上传 `.app` 并提审；内部测试可用 **HUAWEI AppGallery Beta**。

> CI 中鸿蒙构建**默认关闭**（`.github/workflows/release.yml` 的 `ohos-release` job 设了 `if: false`），需在有 Flutter-OH SDK 的**自托管 runner** 上启用，并配置 AGC 的 `client_id` / `client_secret` / keystore 等 Secrets。

---

## 三段协作示意

```
PR / push ──▶ ① GitHub Actions (ubuntu)
              ├─ dart format / dart analyze
              ├─ flutter test            (单元 + Widget)
              └─ flutter build web       (编译校验)

tag / 手动 ──▶ ②+③ Release 流水线 (.github/workflows/release.yml)
   ├─ Android : ubuntu → fastlane android (AAB → Play)
   ├─ iOS     : macos  → fastlane ios   (match + gym + deliver)
   ├─ Desktop : 各平台原生 runner → 原生构建物
   └─ 鸿蒙     : 自托管 (Flutter-OH) → hap → AGC (默认禁用)
```

**经验法则**：一套流水线用 N 次，而不是 N 套。多个 app 共享这些 lane / workflow 模板，仅 per-app 配置不同，Apple 改一次规则只修一处。
