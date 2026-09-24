# Fastlane 与跨平台发布管线调研报告

> 调研时间：2026-09-24 · 适用场景：Flutter + Flutter-OH 7 平台（iOS / Android / 鸿蒙 / Windows / macOS / Linux / Web）应用模板
> 结论先行：Fastlane 不是"完整 CI"，而是**发布层（release layer）**。推荐组合 = GitHub Actions（PR 门禁）+ Fastlane lanes（发布逻辑入仓）+ 托管 macOS CI（iOS 重发布）。鸿蒙无 Fastlane 插件，需走 DevEco 命令行 / hvigor / ohpm + AppGallery Connect API 自建 lane。

---

## 1. Fastlane 是什么 / 不是什么

| 它是什么 | 它不是什么 |
|---|---|
| iOS/Android 发布自动化工具链（Ruby 写 `Fastfile`） | 完整的 CI 系统（不负责编译排队、缓存、PR 门禁） |
| 把"版本号自增、打包、签名、上传商店、截图"脚本化、可本地跑 | 不覆盖 Web / Desktop / 鸿蒙的构建 |
| 换 runner 不丢的"发布逻辑载体" | 不负责单元测试 / 代码分析（那是 CI 的活） |

**关键心智模型**：Fastlane 是铺在水管最底层的"发布逻辑"，上面跑什么 CI（GitHub Actions / Codemagic / Bitrise / 自托管）都行。把发布逻辑写成 Fastlane lanes 存进仓库，最大的好处是**换 CI 厂商时发布逻辑不丢**（Bitrise 的 workflow、Codemagic 的 yaml、EAS 的 eas.json 都不跨平台移植）。

---

## 2. Fastlane 核心组件（按需取用）

| 组件 | 作用 | 我们是否采用 |
|---|---|---|
| `match` | 把证书/Provisioning Profile 存加密 git 仓库，确定性同步——**消灭 90% 的 2am 签名故障** | ✅ 必用（iOS 签名唯一推荐方案） |
| `gym` | 归档打 IPA | ✅ |
| `deliver` | 上传 IPA 到 TestFlight / App Store + 元数据/截图 | ✅ |
| `pilot` | 管理 TestFlight 外部测试员、构建 | ✅（beta 分发） |
| `supply` | 上传 APK/AAB 到 Play Console + 元数据 | ✅（Android） |
| `snapshot` / `frameit` | 多语言/多设备自动截图并加设备边框 | 🟡 可选（正式上架前跑一次） |
| `cert` / `sigh` | 单独管理证书/Profile（match 已涵盖，一般不必单独用） | ❌ |

> 本机已安装 fastlane（路径 `/Users/andy/.rvm/gems/ruby-3.2.2/bin/fastlane`，rvm ruby-3.2.2），可直接复用，无需额外装 Ruby 环境。

---

## 3. 推荐发布管线（业界 2026 共识）

```
PR / push ──▶ GitHub Actions (ubuntu, 免费额度)
              ├─ flutter analyze            (报错即阻断)
              ├─ dart format --set-exit-if-changed
              ├─ flutter test --coverage    (单元 + widget)
              └─ 上传覆盖率

tag / 手动触发 ──▶ Release 流水线
   ├─ Android : GitHub Actions (ubuntu)  keystore 自管 → AAB → fastlane supply
   ├─ Web     : GitHub Actions (ubuntu)  → 静态托管
   ├─ Win/mac/Linux : 各自 runner 原生构建
   ├─ iOS     : GitHub Actions (macos) 或 Codemagic → fastlane match + gym + deliver
   └─ 鸿蒙     : Flutter-OH SDK + hvigor → .hap → AppGallery Connect API 上传
```

**三段分工原则**
1. **PR 门禁用 GitHub Actions（Linux）**：分析/格式化/测试/覆盖率。这部分与移动无关、跑在 Linux 上又快又便宜，且紧贴代码仓库。
2. **发布逻辑全写 Fastlane lanes**：版本自增、打包、签名、上传、商店元数据，入仓、可本地复现、换 runner 不丢。
3. **iOS 重发布用托管 macOS CI**：签名最痛，Codemagic/Bitrise 的托管签名省心；若团队有自托管 Mac 且愿意 owner 这块知识，也可 GitHub Actions macos runner + match。

> 经验法则：**"一套流水线用 N 次，而不是 N 套"**——多 app 共享 lanes / workflow 模板，仅 per-app 配置不同。否则每个 app 各写一套，Apple 改一次规则要修 N 处。

---

## 4. 托管 CI 横向对比（节选）

| 维度 | Fastlane | GitHub Actions | Codemagic | Bitrise |
|---|---|---|---|---|
| 定位 | 发布自动化（随处跑） | 通用 CI runner | 移动专属 CI | 移动 DevOps 平台 |
| 是否懂 Flutter | 仅插件 | 否（你配） | 一等公民 | 预置步骤 |
| iOS 签名 | `match` 显式可移植 | 你脚本（通常借 Fastlane） | 托管引用 | 托管 |
| 商店上传 | 深（TestFlight/Play/分阶段） | 仅你脚本 | 配置即内置 | 配置即内置 |
| 本地调试 | ✅ 最强特性 | 近似（`act`） | ❌ | ❌ |
| 成本模型 | 免费开源 | Linux 免费、macOS 按倍数计费 | 付费档 + 免费额度 | 付费档 |
| 适用 | 所有人的发布底层 | PR 门禁 + Android | iOS 重发布 | 可视化工作流 |

**选型建议**：大多数 Flutter 团队 = GitHub Actions（PR 门禁 + Android）+ Fastlane lanes（全部发布逻辑）+ iOS 卡签名时用 Codemagic。把发布逻辑写进 Fastlane，runner 随便换。

---

## 5. 鸿蒙（HarmonyOS / OpenHarmony）CI/CD 缺口与方案

**现状**：Fastlane 无官方/社区鸿蒙插件。鸿蒙发布链路独立于 iOS/Android：

- 构建：Flutter-OH 的 `flutter build hap --release`（生成 `.hap` / App Pack `.app`）。
- 工具链：DevEco Studio 命令行 / **hvigor**（鸿蒙构建引擎）/ **ohpm**（包管理）。
- 签名：鸿蒙使用 `.p12` 证书 + `.csr` + `SigningConfig`（`signingConfigs` in `build-profile.json5`），通过 **AppGallery Connect**（AGC）管理，与 Apple 体系完全不同。
- 上传/分发：通过 **AppGallery Connect API**（REST）或 `agconnect` CLI 上传 `.app` 并提审；内部测试可用 **HUAWEI AppGallery Beta**。

**模板中的落地方式**
- 在 `fastlane/Fastfile` 内加 `platform :ohos` 或独立 lane `ohos_build`，内部调用 `sh("flutter build hap --release")` 与 hvigor/ohpm/agc 命令（用 `sh` 步骤封装）。
- 或直接在 `.github/workflows/release.yml` 用单独 job（`runs-on: ubuntu`，需配置 Flutter-OH SDK + AGC 凭证 secret）执行构建与上传脚本 `scripts/ohos_release.sh`。
- 凭证管理：AGC 的 `client_id` / `client_secret` / keystore 存 GitHub Secrets，不入库。

> 注意：本机未装 Flutter-OH SDK，模板仅提供 **ohos 接入钩子 + 文档 + 脚本骨架**，真实 `.hap` 构建需用户在装好 Flutter-OH + DevEco 的环境执行。

---

## 6. 测试与发布的关系（为什么测试要进 CI）

测试金字塔要"有人强制跑"才有意义——没人强制跑的测试套件只是文档格式。因此：
- **GitHub Actions PR 门禁**强制 `flutter test`（单元 + widget）通过才能合入，覆盖率门槛（建议 ≥ 70%）作为 analyze 级别的硬阻断。
- **集成测试 / UI 自动化**（`integration_test` + `patrol`）跑在真机/模拟器，作为 release 前或 nightly 任务，而非每个 PR（耗时长、需设备）。
- Fastlane 的 `snapshot` 截图也建议挂在 release 流程而非 PR。

---

## 7. 给本模板的落地清单

1. `fastlane/Fastfile`：`android`（build + supply）、`ios`（match + gym + deliver + pilot）、`ohos`（hvigor/hap 构建 + AGC 上传，脚本骨架）。
2. `fastlane/Matchfile` + `Gemfile` + `fastlane/README.md`（match 初始化步骤、AGC 凭证配置）。
3. `.github/workflows/ci.yml`：PR 门禁（analyze/format/test/coverage，ubuntu）。
4. `.github/workflows/release.yml`：tag 触发，分平台构建 job + 调 fastlane / 脚本。
5. `scripts/bootstrap.sh`：首次 `flutter create --platforms=ios,android,windows,macos,linux,web .` 生成原生目录（ohos 单独用 Flutter-OH SDK 生成）。
6. `docs/CI-CD.md`：讲清三段分工、如何 `fastlane match` 初始化、store 凭证配置、ohos 发布步骤。

---

## 8. 风险与待确认

- **iOS 签名成本**：`match` 首次配置需一个加密 git 仓库 + Apple 开发者账号。建议模板内置 `Matchfile` 与说明，凭证由用户填。
- **鸿蒙工具链成熟度**：hvigor/AGC API 随版本变动，模板脚本以"可替换的封装"形式提供，避免硬绑定特定 CLI 版本。
- **Web 体积/性能边界**：Flutter Web 非一等公民（首屏体积、SEO），如未来某 app 以 Web 为主，建议评估是否走独立 Web 方案，模板不强约束。
