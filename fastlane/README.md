# Fastlane for the Flutter Template

This directory holds the **release layer** for the multi-platform template. The
release logic is written as Fastlane lanes (Ruby) so it is portable across CI
vendors (GitHub Actions, Codemagic, Bitrise, self-hosted).

> Fastlane is *not* a full CI. It sits at the bottom of the pipeline and owns
> versioning, packaging, signing and store uploads. The PR gate (analysis,
> formatting, tests) lives in `.github/workflows/ci.yml`, and the tag-triggered
> orchestration lives in `.github/workflows/release.yml`.

## Prerequisites

```bash
# Ruby is required (template assumes Ruby 3.x; the host used for research was
# Ruby 3.2.2 managed via rvm).
bundle install        # installs fastlane from the Gemfile
```

## Lanes

| Lane | Command | What it does |
|------|---------|--------------|
| Android | `bundle exec fastlane android release` | `flutter build appbundle` + upload to Play internal track |
| iOS | `bundle exec fastlane ios release` | `match` + `flutter build ios` + `gym` + `deliver` + `pilot` |
| macOS | `bundle exec fastlane macos release` | `flutter build macos` (wrap as DMG) |
| Windows | `bundle exec fastlane windows release` | `flutter build windows` (wrap with InnoSetup/NSIS) |
| Linux | `bundle exec fastlane linux release` | `flutter build linux` (wrap as AppImage) |
| HarmonyOS | `bundle exec fastlane ohos release` | `flutter build hap` (placeholder; needs Flutter-OH) |

## iOS signing with `match`

1. One-time, locally: `bundle exec fastlane match init` — point it at a **private**
   git repo (e.g. `https://github.com/your-org/certs-repo.git`).
2. Generate the certs/profile: `bundle exec fastlane match appstore`.
3. In CI, set these secrets (do **not** commit them):
   - `MATCH_GIT_URL`
   - `MATCH_PASSWORD` (repo decryption passphrase)
   - `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`
   - `APPLE_ID`, `APPLE_TEAM_ID`

The iOS lane uses `match(type: "appstore", readonly: true)` so CI only reads,
never regenerates, signing assets.

## Android store credentials

- Create a Play Console **service account** and download the JSON key.
- Place it at `fastlane/play-key.json` (git-ignored) **or** export
  `SUPPLY_JSON_KEY_FILE` pointing to it.
- `upload_to_play_store` pushes to the `internal` track by default.

## HarmonyOS (no Fastlane plugin)

Fastlane cannot build or upload HarmonyOS packages. The `ohos` lane simply shells
out to the Flutter-OH toolchain (`flutter build hap --release`). For signing and
AppGallery Connect distribution, follow `docs/CI-CD.md` (hvigor + AGC API).

## One-liner for local release dry-run

```bash
bundle exec fastlane android release  # or: ios / macos / windows / linux
```
