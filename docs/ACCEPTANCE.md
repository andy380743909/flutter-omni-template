# 本地验收清单（Acceptance Checklist）

> 本模板在**交付环境没有 Flutter SDK**，所有代码均为静态审查（类型/import/测试逻辑一致性）。
> 以下是在你本机（装有 Flutter stable）做**真实验收**的步骤与预期结果。

## 前置

- Flutter stable（≥ 3.22），`flutter doctor` 无致命项。
- Ruby + Bundler（仅发布阶段需要，运行 Fastlane）。
- 鸿蒙见 `ohos/README.md`（需 Flutter-OH SDK，单独环境）。

## 1. 生成原生平台目录并取依赖

```bash
bash scripts/bootstrap.sh     # 生成 ios/android/windows/macos/linux/web
flutter pub get              # 拉依赖 + 自动生成 l10n 代码
```

预期：`scripts/bootstrap.sh` 输出 6 平台目录生成成功；`flutter pub get` 无错误，并生成 `lib/shared/l10n/generated/`。

## 2. 静态分析与测试（PR 门禁等价）

```bash
dart analyze --fatal-warnings     # 预期：无 warning
flutter test                     # 预期：test/ 全绿（counter + profile 单元测试）
flutter test test_features       # 预期：Widget 测试全绿（三态 UI）
```

- counter 单测：`GetCounter`/`IncrementCounter` 成功与失败路径、`CounterCubit` 四态发射序列、`CounterModel` JSON 往返。
- profile 单测：`GetProfile` 成功/失败、`ProfileCubit` 四态、`ProfileModel` 校验缺失字段抛 `FormatException`、JSON 往返。
- Widget 测试：用 `MockCubit` 覆盖 initial/loading/loaded/error 三态 + 按钮回调 `verify`。

## 3. 运行应用

```bash
flutter run
```

- **Counter 页**：点 `+` → 计数 +1 并持久化（杀掉重开仍保留）。右上角「人头」图标进入 Profile 页。
- **Profile 页**：默认 `AppConfig.apiBaseUrl = https://api.example.com`，而 `/profile` 是占位端点，**无真实后端时会走 network 失败 → 本地缓存为空 → 显示错误态**。这是预期行为，证明「远程优先 + 缓存回退」链路工作正常。
  - 想让 Profile 真正取到数据：把 `lib/core/config/app_config.dart` 的 `apiBaseUrl` 指向一个返回 `{id,name,email}` 的接口（或用 `--dart-define=API_BASE_URL=...`），即可看到头像/姓名/邮箱卡片。
  - 已缓存后断网：会回退显示上一次成功的 profile（验证 `ProfileRepositoryImpl` 的离线分支）。

## 4. 集成 / UI 自动化（需设备/模拟器，不在公共 CI）

```bash
flutter test integration_test        # 端到端：启动 → 点击+ → 计数持久化
# patrol（系统级交互，需 patrol_cli + 真机/模拟器原生改造）
patrol test integration_test/counter_patrol_test.dart
```

## 5. 鸿蒙（单独环境）

见 `ohos/README.md` 与 `docs/CI-CD.md`：装 Flutter-OH → `flutter create --platforms=ohos .` → 配签名 → `bash scripts/ohos_release.sh`（内含 AGC 上传）。公共 CI 默认不构建鸿蒙。

## 验收判据（Definition of Done）

- [ ] `dart analyze --fatal-warnings` 零 warning
- [ ] `flutter test` 与 `flutter test test_features` 全绿
- [ ] `flutter run` 后 Counter 计数持久化、跨页跳转正常
- [ ] Profile 在指向真实后端时显示卡片；无后端时显示错误态（不崩溃）
- [ ] 各平台 `flutter build <platform> --release` 可产出（桌面/移动按需本机验证）
