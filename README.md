# App Template — 可复用跨平台 Flutter 应用模板

一套 Dart 代码覆盖 **7 个平台**：iOS / Android / **HarmonyOS（鸿蒙, Flutter-OH）** / Windows / macOS / Linux / Web。

基于 **Clean Architecture 变体** + `flutter_bloc`（Cubit）+ `get_it`（DI）+ `dio` + `shared_preferences`，强可测试、模式可复制。新建业务 app 时 `git clone` / 复制本仓库，把 `lib/features/counter` 与 `lib/features/profile` 两个示例 feature 换成你的业务即可。

> 这是**工程模板**，不含任何真实业务，只提供可运行的 App Shell 与完整模式示范。

---

## 定位与边界（请先读）

| 它是… | 它不是… |
|------|---------|
| **模板 / App Shell**：你 copy 它作为新项目的起点 | 一个 clone 即跑的 **demo**（需先 bootstrap + 装 Flutter） |
| 一套**已搭好的工程约定**：目录分层、DI、状态管理、三层测试、CI、Fastlane | 一个包含真实业务逻辑的成品 App |
| 面向**已会 Flutter** 的开发者，省去每次重搭脚手架 | 面向初学者的教学项目 |

> **适用人群**：已决定用 Flutter、想要"干净架构 + 可测试 + 多平台 + 发布流水线"开箱即用的独立开发者 / 小团队。
> **不适用**：一次性小工具、不想接受这套目录/状态管理约定的项目、纯学习 Flutter 的新手（先用官方 `flutter create` 更合适）。

## 验证状态（诚实说明）

✅ **本仓库已用真实 Flutter 3.47.5 SDK 实测过了一遍**（`flutter create` 生成的 6 平台原生目录已随仓库提交，clone 即可用，无需再跑 `bootstrap.sh` 生成）。实测结果：

| 检查项 | 命令 | 结果 |
|--------|------|------|
| 静态分析 | `flutter analyze --fatal-warnings` | ✅ 通过（仅剩 `prefer_const_constructors` 等 info 级提示，不阻断 CI） |
| 单元测试 + widget 测试 | `flutter test` | ✅ 27 个全部通过 |
| Web 构建 | `flutter build web --release` | ✅ 成功 |
| macOS 构建 | `flutter build macos --release` | ✅ 成功 |
| iOS 构建 | `flutter build ios --release --no-codesign` | ✅ 成功（未签名，仅编译验证） |

⚠️ **本机（macOS）只能实测 web / macOS / iOS 三个平台的构建**；Android / Windows / Linux 因缺对应 OS 与 SDK 未在本机编译，但 CI 会分别用 ubuntu（android/linux）与 windows runner 构建，且三者共享同一套 Dart 代码（已在本机跨平台编译验证）。请按 `docs/ACCEPTANCE.md` 做一次全平台验收。

🛠 **为让"每平台都能跑 hello world"而修掉的阻断问题**（均为真实编译错误）：
- 各 usecase / 测试文件漏 `import '.../result.dart'`，且 `Result.success/failure` 工厂未声明 `const` → 改显式 import + `const factory`；
- `get_profile.dart` 漏 `import '.../failures.dart'`（`Failure` 找不到）；
- `DefaultLogger` 误用 `printEmoji`（logger 2.8.0 实际参数为 `printEmojis`）；
- `PlatformInfoImpl()` 非 const 构造器却被 `const` 调用；
- l10n 改用显式 `output-dir: lib/shared/l10n/generated` + 普通 `package:` 导入，弃用脆弱的 `flutter_gen` 合成包（`app.dart` 导入路径已同步修改）。

CI 的 `flutter-version` 固定为 **3.47.5**；鸿蒙需单独的 Flutter-OH SDK（见下文）。

---

## 平台最低系统版本（重要）

Flutter **每个平台都有最低系统版本限制，且会随 Flutter 升级而抬高**（3.47 刚把 iOS 最低从 13 升到 15、macOS 从 10.15 升到 12）。下表基于 Flutter **3.47.x** 官方支持矩阵：

| 平台 | 最低版本 | 最高（3.47） | 架构 | 备注 |
|------|----------|--------------|------|------|
| **Android** | API 24（Android 7.0） | API 36/37（≈Android 16） | arm64 / x64 / arm32 | `minSdk` 默认 24；`targetSdk` 默认 36（Google Play 自 2026-08-31 强制 target 36） |
| **iOS** | **iOS 15** | iOS 26 | **仅 arm64** | 3.47 把最低从 13 升到 15；CI 实测 18 与 26 |
| **Windows** | Windows 10 | Windows 11 | x64 / arm64 | — |
| **macOS** | **macOS 12 Monterey** | macOS 26 Tahoe | arm64 / x64 | **Intel x64 正被弃用**：警告将来变 error；建议 `flutter config --enable-macos-arm64-only` |
| **Linux (Ubuntu)** | 20.04 LTS | 24.04 LTS | x64 / arm64 | 仅 LTS |
| **Linux (Debian)** | 10 | 13 | x64 / arm64 | — |
| **Web (Chrome/Edge)** | 最近 2 个大版本 | — | JS + **Wasm** | Wasm 正走向默认，需 `package:web` |
| **Web (Safari)** | 15.6 | — | JS | — |
| **Web (Firefox)** | 最近 2 个大版本 | — | JS only | — |
| **HarmonyOS（鸿蒙）** | **API 12（5.0.0(12)）** | — | 见下 | 非官方 Flutter，需 Flutter-OH，版本分裂见"鸿蒙单独步骤" |

> **⚠️ 测试机提醒（iPhone X 用户必读）**：Flutter 3.47 支持 iOS 15–26，你的 **iPhone X（iOS 16）仍在范围内、能跑**。但 iPhone X 的 A11 芯片**最高只能升到 iOS 16**——**若未来 Flutter 把最低要求抬到 iOS 17，iPhone X 会直接出局**。建议主力验收用 **iPhone 15（iOS 16 但可升 26）**，iPhone X 仅作老机型内存/性能压力测试。macOS/Web 同理受其最低版本钳制。

---

## 目录结构（要点）

```
./
├── pubspec.yaml / analysis_options.yaml / l10n.yaml
├── scripts/bootstrap.sh        # 生成 6 平台原生目录 + 鸿蒙指引
├── Makefile                    # bootstrap / get / analyze / test / test-int
├── fastlane/                   # 多平台发布 lanes（Fastfile / Appfile / Matchfile）
├── .github/workflows/          # ci.yml（PR 门禁）/ release.yml（tag 发布）
├── lib/
│   ├── main.dart / app/        # 入口与装配（bootstrap / MyApp / environment）
│   ├── core/                   # 纯 Dart、平台无关、100% 可测
│   ├── features/counter/       # 示例 feature：本地存储计数（domain / data / presentation）
│   ├── features/profile/       # 示例 feature：网络+缓存（HttpClient/dio + KeyValueStorage）
│   ├── shared/                 # 主题 / l10n / 通用 widget
│   ├── platforms/              # per-platform 实现（storage / platform_info）
│   └── di/                     # get_it 依赖注入装配
├── test/                       # 单元测试
├── test_features/              # Widget 测试
└── integration_test/           # 集成测试 + patrol
```

---

## 前置依赖

| 工具 | 用途 | 说明 |
|------|------|------|
| **Flutter（stable）** | 构建 6 官方平台 | `flutter --version` 建议 ≥ 3.22 |
| **Dart SDK** | 随 Flutter 自带 | `dart --version` 建议 ≥ 3.4 |
| **Ruby ≥ 3.x + Bundler** | 运行 Fastlane | 仅发布阶段需要；研究环境用 rvm + Ruby 3.2.2 |
| **Flutter-OH SDK** | 仅鸿蒙需要 | 鸿蒙适配版 Flutter，见下文"鸿蒙单独步骤" |
| **patrol_cli（可选）** | 跑 patrol UI 自动化 | `dart pub global activate patrol_cli`，不进 pubspec |

---

## 用户本地首次运行（三条命令）

```bash
# 1. 生成 6 平台原生目录（ios/android/windows/macos/linux/web）
bash scripts/bootstrap.sh

# 2. 拉取依赖（同时自动生成 l10n 代码）
flutter pub get

# 3. 启动应用
flutter run
```

---

## 各测试层命令

| 层级 | 目录 | 命令 |
|------|------|------|
| 单元测试 | `test/` | `flutter test` |
| Widget 测试 | `test_features/` | `flutter test test_features` |
| 集成测试 | `integration_test/` | `flutter test integration_test` |
| patrol UI 自动化 | `integration_test/counter_patrol_test.dart` | `patrol test integration_test/counter_patrol_test.dart` |

> 本地真实验收清单（含本环境无 Flutter 的说明、各 feature 预期行为）见 [`docs/ACCEPTANCE.md`](docs/ACCEPTANCE.md)。

或统一用 `make`：`make analyze` / `make test` / `make test-int` / `make ci`。

---

## 各平台构建命令

```bash
flutter build apk --release          # Android
flutter build appbundle --release    # Android (Play)
flutter build ios --release          # iOS（需 macOS + 签名）
flutter build macos --release        # macOS
flutter build windows --release      # Windows
flutter build linux --release        # Linux（需 gtk 依赖）
flutter build web --release          # Web
```

---

## Fastlane lanes 用法

```bash
bundle install                       # 安装 fastlane（见 Gemfile）
bundle exec fastlane android release # AAB → Play 内部轨道
bundle exec fastlane ios release     # match + gym + deliver + pilot
bundle exec fastlane macos release   # 打包 macOS
bundle exec fastlane windows release # 打包 Windows
bundle exec fastlane linux release   # 打包 Linux
```

iOS 签名用 `match`：本地先 `bundle exec fastlane match init`，CI 配置 `MATCH_GIT_URL` / `MATCH_PASSWORD` 等 Secrets（详见 `fastlane/README.md` 与 `docs/CI-CD.md`）。

---

## 鸿蒙（HarmonyOS）单独步骤

> ⚠️ **版本分裂**：鸿蒙由 OpenHarmony SIG 社区维护的 Flutter-OH 提供，**版本号与官方 Flutter 不对应、且落后**（官方 3.47 无鸿蒙版，社区最新约 3.35.7dev）。HarmonyOS NEXT 需 **API 12（5.0.0(12)）及以上**，请用 `3.22.0-ohos` 等社区稳定版，**勿复用本模板钉的官方 `3.47.5`**。详见 `docs/CI-CD.md`。

鸿蒙**不在**官方 Flutter 之内，需 `flutter create` 之外的独立流程（且需要 Flutter-OH SDK 环境）：

```bash
# 在装有 Flutter-OH SDK 的机器上，把 Flutter-OH 的 flutter 放到 PATH
flutter create --platforms=ohos .
flutter build hap --release
```

- 签名 / 上传走 **AppGallery Connect（AGC）**，与 Apple 体系不同（`.p12` + `SigningConfig` + AGC API）。
- 公共 CI 默认**不构建**鸿蒙（`.github/workflows/release.yml` 的 `ohos-release` job 设 `if: false`），需在自托管 runner 启用。
- 详见 `docs/CI-CD.md` 与 `docs/FASTLANE_RESEARCH.md`。

---

## bootstrap 后需手动微调的点

`scripts/bootstrap.sh` 生成的官方平台原生目录里有几处**需按 app 实际情况手动修改**（模板不替你写死）：

- **Android**（`android/app/src/main/AndroidManifest.xml`）：补齐权限（网络、相机、定位等）、`applicationId`、`android:label`。
- **iOS**（`ios/Runner/Info.plist`）：配置 `CFBundleDisplayName`、隐私权限描述（NS*UsageDescription）、URL Scheme。
- **Web**（`web/index.html`）：修改 `<title>`、`<meta description>`、PWA 图标与 manifest。
- **桌面**：Windows/macOS/Linux 的窗口标题、图标在各自 `*/Runner` 工程中调整。
- **鸿蒙**：DevEco 工程里的 `AppScope/app.json5`、`module.json5`、`build-profile.json5` 与签名配置（Flutter-OH 环境另行处理）。

---

## 编码约定

- 行宽 **100** 字符；提交前 `dart format .`。
- 禁止业务代码用 `print`，统一走 `core/utils/logger.dart` 的 `Logger` 接口。
- 状态管理用 Cubit，state 四态：`initial / loading / loaded / error`（手写不可变类）。
- 错误：data 层抛 `Exception` → 转 `Failure` → 经 `Result.failure` 上抛；UI 只消费 state。
- DI 集中在 `lib/di/injection_container.dart`；Cubit 用 `registerFactory`，其余 `registerLazySingleton`。

详见 `docs/design/ARCHITECTURE.md` 与 `docs/design/TASKS.md`。

---

## 基于本模板创建新 App（实例化指南）

本仓库是**可复用的 app 基座**。每开发一个新 app，按下面的步骤"派生"即可，无需从零搭脚手架。

### 1. 派生仓库

```bash
# 方式 A：作为新仓库起点（推荐）
git clone <本模板地址> my_new_app
cd my_new_app
rm -rf .git && git init && git add -A && git commit -m "chore: init from app_template"

# 方式 B：作为 GitHub Template（在 GitHub 点 "Use this template"），clone 后同上

# 重新生成原生平台目录（保留 lib/ 与配置，只重铺 ios/android/...）
bash scripts/bootstrap.sh
flutter pub get
```

### 2. 改包名（关键，必须做）

模板的 Dart 包名是 `app_template`，所有 `import 'package:app_template/...'` 都依赖它。新 app 改名用全量替换：

```bash
# 把 app_template 改成你的包名（例如 my_new_app），需同步改 pubspec.yaml 的 name
OLD=app_template NEW=my_new_app
sed -i '' "s/package:$OLD\//package:$NEW\//g" $(grep -rl "package:$OLD/" lib test test_features integration_test)
sed -i '' "s/^name: $OLD/name: $NEW/" pubspec.yaml
flutter pub get      # 校验 import 全部解析成功
```

> 鸿蒙 `ohos/` 目录是 `flutter create --platforms=ohos` 单独生成的，里面的包名/签名需按 AGC 工程另行配置，不在此 sed 范围内。

### 3. 替换示例 feature

`lib/features/counter/` 是**模式示范**，新 app 里通常：

- **保留作参考**：复制 `lib/features/counter/` 为 `lib/features/<你的feature>/`，照着 domain/data/presentation 三层改。
- **或整目录删除**：`rm -rf lib/features/counter test/features/counter test_features/features/counter integration_test/*counter*`，再把 `lib/app/app.dart` / `lib/di/injection_container.dart` 里对 `CounterCubit` 的引用清掉。

复制后必改的检查清单：

| 位置 | 改动 |
|------|------|
| `domain/entities/*` | 你的业务实体（可不加 `Equatable`，手写 `==`/`hashCode`） |
| `domain/repositories/*` | 抽象接口（仅签名） |
| `domain/usecases/*` | 用例（`extends UseCase<Return, Params>`） |
| `data/models/*` | `fromJson/toJson` 数据模型 |
| `data/datasources/*` | 本地/远程数据源 |
| `data/repositories/*` | 实现接口，注入 datasource，返回 `Result<Entity, Failure>` |
| `presentation/state/*` | `XxxState`（四态不可变）+ `XxxCubit`（注入 usecases） |
| `presentation/pages/*` | 页面，`BlocProvider` + `BlocBuilder` |
| `lib/di/injection_container.dart` | 注册新 repository/datasource/cubit |
| `lib/app/app.dart` | 路由/首页挂上你的 feature |

### 4. 提交你的第一笔业务代码

```bash
dart format .
dart analyze --fatal-warnings
flutter test && flutter test test_features
git add -A && git commit -m "feat: add <your feature>"
```

### 5. 接入 CI / 发布（按需）

- CI 门禁默认已开：推送 → `.github/workflows/ci.yml` 跑 analyze + 单测 + Widget 测 + 各平台 build 校验。
- 发布：打 `v*` tag 触发 `.github/workflows/release.yml` → 调 `fastlane <platform> release`。
- 鸿蒙需单独在装有 Flutter-OH 的 runner 上启用 `ohos-release` job（见 `docs/CI-CD.md`）。

---

## 模板维护约定（给维护者）

- 模板只放**通用骨架与模式示范**，不堆砌具体业务；新增通用能力（如日志上报、网络拦截器）请放在 `lib/core/` 或 `lib/shared/`。
- 每次升级 Flutter / 关键依赖（flutter_bloc、bloc、get_it、dio 等大版本）后，跑一遍 `flutter test` + `flutter test test_features` 确认示例 feature 仍绿。
- 示例 feature 是"活文档"：它的通过与否代表模板本身没坏。
