# 贡献指南（本模板的维护约定）

本仓库是**可复用的跨平台 Flutter 应用模板**。维护目标：保持骨架干净、模式示范正确、每个示例 feature 的测试始终为绿。

## 加入一个新 feature（照此复制）

以 `lib/features/counter/` 与 `lib/features/profile/` 为样板，新建 `lib/features/<name>/`，严格分层：

```
features/<name>/
  domain/
    entities/<name>.dart            # 纯 Dart 实体（手写 ==/hashCode）
    repositories/<name>_repository.dart   # 抽象接口（仅签名）
    usecases/<use_case>.dart        # extends UseCase<Return, Params>
  data/
    models/<name>_model.dart        # fromJson/toJson/fromEntity/toEntity
    datasources/<name>_{remote,local}_datasource.dart  # 抽象 + 实现
    repositories/<name>_repository_impl.dart  # 实现接口，返回 Result<Entity, Failure>
  presentation/
    pages/<name>_page.dart          # BlocProvider + BlocBuilder
    widgets/<name>_xxx.dart         # 可复用展示部件
    state/<name>_state.dart         # 四态不可变（initial/loading/loaded/error）
    state/<name>_cubit.dart         # 注入 usecases，先 emit loading 再 loaded/error
```

然后在 `lib/di/injection_container.dart` 注册（datasource/repository 用 `registerLazySingleton`，Cubit 用 `registerFactory`），并在 `lib/app/app.dart` 接入路由。

## 测试要求（PR 门禁）

每个 feature 至少提供：

- **单元测试** `test/features/<name>/...`：用 `mocktail` mock repository/datasource，`bloc_test` 测 Cubit 的四态发射序列。
- **Widget 测试** `test_features/features/<name>/...`：用 `bloc_test` 的 `MockCubit` 驱动 UI 三态（**禁止**裸 `Mock implements Cubit`，否则 `stream` 为 null 会崩溃）。
- 涉及真实端到端路径时，加 `integration_test/`。

提交前本地必须全绿：

```bash
dart format .
dart analyze --fatal-warnings
flutter test && flutter test test_features
```

## 提交信息

采用 Conventional Commits：`feat:` / `fix:` / `chore:` / `docs:` / `test:` / `refactor:`。示例 feature 的通过与否代表模板本身没坏——改了 core/ 或 DI，请确认两个示例 feature 测试仍绿。

## 分支与发布

- 主干保护，PR 合并前过 `.github/workflows/ci.yml`。
- 打 `v*` tag 触发 `.github/workflows/release.yml` → `fastlane <platform> release`。
- 鸿蒙（Flutter-OH）需单独在装有 Flutter-OH 的 runner 上启用 `ohos-release` job。
