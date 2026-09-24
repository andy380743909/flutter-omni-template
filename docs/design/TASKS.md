# 可复用跨平台 Flutter 应用模板 — 任务分解

> 配套文档：[ARCHITECTURE.md](./ARCHITECTURE.md)
> 本文给出**有序任务列表 + 依赖包清单 + 共享约定 + 待明确事项**。
> 任务仅描述「产出什么、依赖什么、如何验收」，**不要求本阶段编写应用源码**（源码由工程师按文档实现）。

---

## 1. 依赖包清单（pubspec.yaml 规划）

> 版本为撰写时的建议值，落地时以 `flutter pub outdated` 校验、取与所用 Flutter 版本兼容的最新版。
> `dev_dependencies` 项已在「类型」列标注。

| 包 | 版本建议 | 类型 | 用途 |
|----|----------|------|------|
| `flutter_bloc` | ^8.1.3 | 依赖 | 状态管理（Cubit/Bloc） |
| `bloc` | ^8.1.2 | 依赖 | bloc 核心（flutter_bloc 传递，可显式声明） |
| `get_it` | ^7.7.0 | 依赖 | 依赖注入单例容器 |
| `dio` | ^5.4.3 | 依赖 | HTTP 客户端实现（core/network） |
| `shared_preferences` | ^2.3.2 | 依赖 | KeyValueStorage 的实现后端 |
| `logger` | ^2.4.0 | 依赖 | 日志输出（core/utils/logger 默认实现包裹它） |
| `flutter_lints` | ^4.0.0 | **dev** | 基础 lint 规则（analysis_options 引用） |
| `very_good_analysis` | ^6.0.0 | **dev（可选）** | 更严格规则集，模板默认注释启用 |
| `mocktail` | ^1.0.3 | **dev** | 单测/Widget 测试 mock（无 codegen） |
| `bloc_test` | ^9.1.7 | **dev** | Cubit/Bloc 测试辅助 |
| `integration_test` | SDK | **dev** | 端到端集成测试（Flutter SDK 自带，dev_dependencies 声明 `sdk: flutter`） |
| `patrol` | ^3.2.0 | **dev** | 系统级 UI 自动化（权限弹窗/深链/分享） |
| `patrol_cli` | — | **全局工具** | `dart pub global activate patrol_cli`，不在 pubspec 内 |
| `flutter_localizations` | SDK | 依赖 | l10n（gen-l10n 需要，sdk: flutter） |
| `intl` | ^0.19.0 | 依赖 | 与 gen-l10n 配合（日期/数字格式化） |

> 可选升级（非默认，待团队确认，见 ARCHITECTURE §13）：`freezed` + `freezed_annotation`（state/model 代码生成）、`injectable` + `injectable_generator`（DI 代码生成）、`flutter_secure_storage`（加密存储）。

---

## 2. 有序任务列表（按实现顺序）

> 依赖关系用「前置任务」列表达。验收标准以「可独立验证」为准则。

### T01 — 工程脚手架与配置
- **前置任务**：无
- **产出文件**：`pubspec.yaml`、`analysis_options.yaml`、`l10n.yaml`、`.gitignore`、`README.md`、`bootstrap.dart`
- **说明**：声明 §1 全部依赖；`bootstrap.dart` 为脚本，负责 `flutter create --platforms=ios,android,windows,macos,linux,web .` 生成 6 平台原生目录，并打印鸿蒙（Flutter-OH）独立生成指引；`README` 写明使用步骤。
- **验收标准**：
  1. `pubspec.yaml` 在含 Flutter SDK 环境能 `flutter pub get` 成功；
  2. `dart analyze` 对配置文件无 error；
  3. `bootstrap.dart` 在 6 平台 Flutter 环境下可生成对应原生目录（鸿蒙步骤以文档/占位形式给出，不报错退出）。

### T02 — core 平台无关基础层
- **前置任务**：T01
- **产出文件**：`lib/core/errors/*`、`lib/core/utils/{result,logger,extensions}.dart`、`lib/core/network/{http_client,dio_http_client}.dart`、`lib/core/storage/key_value_storage.dart`、`lib/core/config/app_config.dart`、`lib/core/usecases/usecase.dart`、`lib/core/platform/{app_platform,platform_info}.dart`
- **说明**：实现 ARCHITECTURE §2/§9 的纯 Dart 核心；`Result`/`Failure`/`Exception` 模型；`HttpClient` 接口 + dio 实现；`KeyValueStorage` 接口；`PlatformInfo` 含鸿蒙 MethodChannel 占位（见 §8）。
- **验收标准**：
  1. `core/` 不 import `dart:io`/`dart:html` 之外的平台 API，可在纯 Dart（`dart test`）下编译；
  2. `dart analyze` 0 warning；
  3. `Result` 的 success/failure 分支单测通过。

### T03 — 依赖注入装配
- **前置任务**：T01、T02
- **产出文件**：`lib/di/injection_container.dart`、`lib/platforms/storage/shared_preferences_storage.dart`、`lib/platforms/platform_info/platform_info_impl.dart`
- **说明**：按 ARCHITECTURE §6 顺序注册；实现 `KeyValueStorage`（shared_preferences）与 `PlatformInfo` 具体解析；`initDi()` 异步初始化。
- **验收标准**：
  1. `initDi()` 完成后 `sl<CounterRepository>()` 等可解析；
  2. `PlatformInfo.current` 在 6 平台正确识别，`isOhos` 在 6 平台下为 false（不抛异常）。

### T04 — 示例 feature：counter 完整实现
- **前置任务**：T02、T03
- **产出文件**：`lib/features/counter/domain/**`、`lib/features/counter/data/**`、`lib/features/counter/presentation/**`
- **说明**：演示完整 clean architecture 模式（domain 抽象 / data 实现 / presentation Cubit）——这是模板「可复制」的样板。
- **验收标准**：
  1. `CounterCubit` 对 `GetCounter`/`IncrementCounter` 的 emit 行为正确（loading→loaded/error）；
  2. `CounterRepositoryImpl` 经 `CounterLocalDataSource` 读写 `KeyValueStorage`；
  3. `CounterModel` 与 `Counter` 实体映射正确（单测覆盖）。

### T05 — 应用入口与共享层
- **前置任务**：T03、T04
- **产出文件**：`lib/main.dart`、`lib/app/{app,bootstrap,environment}.dart`、`lib/shared/theme/app_theme.dart`、`lib/shared/l10n/{app_en.arb,app_zh.arb}`、`lib/shared/widgets/{app_error,app_loading}.dart`
- **说明**：`main()` → `bootstrap()`（日志/环境/`initDi()`）→ `runApp(MyApp)`；`MyApp` 接主题与 l10n；接入 `CounterPage`。
- **验收标准**：
  1. `flutter run` 在任一平台启动并显示 counter 页面，点击 + 计数自增并持久化；
  2. 中英文切换生效（gen-l10n 产物可用）。

### T06 — 单元测试（core + usecase + cubit）
- **前置任务**：T02、T04
- **产出文件**：`test/core/**`、`test/features/counter/**`
- **说明**：用 `mocktail` mock repository 接口；覆盖 `Result` 逻辑、`CounterCubit` 状态序列、`usecase` 成功/失败分支、`CounterModel` 映射。
- **验收标准**：`flutter test` 全绿；core 逻辑覆盖率 ≥ 90%。

### T07 — Widget 测试（presentation）
- **前置任务**：T04、T05
- **产出文件**：`test_features/features/counter/**`
- **说明**：用 `WidgetTester` + mock cubit 验证 `CounterPage`/`CounterDisplay` 的渲染与交互（点击按钮触发 cubit 方法，显示对应 state）。
- **验收标准**：`flutter test test_features` 全绿；加载/错误/成功三态 UI 均被覆盖。

### T08 — 集成测试 + patrol 自动化
- **前置任务**：T05
- **产出文件**：`integration_test/app_test.dart`、`integration_test/counter_patrol_test.dart`
- **说明**：`integration_test` 跑端到端用户流（启动→点击→计数持久化）；`patrol` 用例演示系统级交互（权限/分享占位）。
- **验收标准**：`flutter test integration_test` 或 `patrol test` 在模拟器/真机通过。

### T09 — GitHub Actions CI 管线
- **前置任务**：T01、T06、T07
- **产出文件**：`.github/workflows/ci.yml`
- **说明**：见 ARCHITECTURE §11.1：`pub get → analyze → unit/widget test → build 校验`。
- **验收标准**：推送 PR 后 CI 自动运行且 analyze 0 warning、测试全绿才允许合并。

### T10 — Fastlane + 鸿蒙构建管线
- **前置任务**：T01
- **产出文件**：`fastlane/Fastfile`、`fastlane/Appfile`、`fastlane/README.md`、`.github/workflows/release.yml`
- **说明**：按平台分 lane（android/ios/桌面）；鸿蒙 lane 以 Flutter-OH `flutter build hap` 占位 + 文档链接；`release.yml` 在打 tag 时触发。
- **验收标准**：本地 `fastlane android` / `fastlane ios` 可产出对应构建物（或 dry-run 成功）；鸿蒙步骤文档可执行（在有 Flutter-OH SDK 环境）。

---

## 3. 共享约定

### 3.1 命名规范
- 目录全小写、以功能聚合：`features/counter/domain/usecases`。
- 文件蛇形：`counter_cubit.dart`、`counter_repository_impl.dart`。
- 类帕斯卡：`CounterCubit`、`CounterRepository`；抽象接口名以 `Repository`/`Storage`/`Client` 等名词，实现加 `Impl`。
- 测试文件同名加 `_test`：`counter_cubit_test.dart`；集成测试放 `integration_test/`。

### 3.2 错误处理（Failure vs Exception）
- **Exception**：仅在 data/datasource 内部抛出（网络、解析等底层意外）。
- **Failure**：域错误，由 data 层 catch Exception **转换**后，经 `Result.failure` 上抛；UI 只感知 state。
- 禁止在 presentation / domain 抛平台相关异常。

### 3.3 日志
- 统一经 `core/utils/logger.dart` 的 `Logger` 接口；禁止直接使用 `print` 输出业务日志。
- 日志级别：dev 全量，prod 仅 warning+。

### 3.4 代码格式化
- 行宽 **100 字符**（`analysis_options.yaml` 设 `line_length: 100`）。
- 提交前 `dart format .`；CI 用 `dart analyze` 0 warning 门禁。
- 不提交 `// TODO` 遗留的业务逻辑 todo（模板自身的占位注释除外）。

### 3.5 依赖注入
- 所有注册集中在 `lib/di/injection_container.dart`；禁止在 widget 里 `GetIt.instance<X>()` 直接取业务对象（Cubit 由 `BlocProvider` 注入，其内部由 DI 提供）。
- 单例用 `registerLazySingleton`，需要新实例的 Cubit 用 `registerFactory`。

---

## 4. 待明确事项（同 ARCHITECTURE §13，供排期参考）

1. Flutter-OH 版本/命令随 SDK 演进，发布管线需按当时文档微调。
2. 是否引入 `freezed`（state/model 代码生成）——默认手写，待确认。
3. l10n 是否升级到 `easy_localization`/`intl` 高级能力——默认 gen-l10n。
4. push / share / 深链 等平台能力抽象接口，后续 feature 按需按「接口 + per-platform 实现」扩展。
5. 是否将加密存储（`flutter_secure_storage`）列为模板标配。

---

> 任务分解结束。工程师按 T01→T10 顺序实现，每步以「验收标准」为完成门槛。
