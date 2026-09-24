# App Template — 可复用跨平台 Flutter 应用模板

一套 Dart 代码覆盖 **7 个平台**：iOS / Android / **HarmonyOS（鸿蒙, Flutter-OH）** / Windows / macOS / Linux / Web。

基于 **Clean Architecture 变体** + `flutter_bloc`（Cubit）+ `get_it`（DI）+ `dio` + `shared_preferences`，强可测试、模式可复制。新建业务 app 时 `git clone` / 复制本仓库，把 `lib/features/counter` 换成你的 feature 即可。

> 这是**工程模板**，不含任何真实业务，只提供可运行的 App Shell 与完整模式示范。

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
│   ├── features/counter/       # 示例 feature（domain / data / presentation）
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
