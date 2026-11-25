# AGENTS.md

## Overview

Eesti Ilm is an iOS weather app for Estonia. It shows the forecast from the Estonian Environment Agency's weather service ([ilmateenistus.ee](https://www.ilmateenistus.ee)) in a forecast list and a home-screen widget. This repo is the top of a chain of repos with the same owner: **Eesti-Ilm** → [weatherCore](https://github.com/Shiaulis/weatherCore) (forecast fetching and XML parsing) → [networking](https://github.com/Shiaulis/networking) (HTTP layer). The project is being revived: version 3.0 is in development and the app is temporarily not on the App Store.

## Requirements

- Xcode 27.2 or later, Swift 6 language mode
- Minimum deployment target: iOS 27.0
- SwiftFormat from Homebrew: `brew install swiftformat`
- For releases only: Ruby (version in `.ruby-version`) and Bundler

## Repo layout

| Path | Contents |
| --- | --- |
| `EstonianWeather.xcodeproj` | Xcode project. Schemes: `EstonianWeather`, `EstonianWeatherWidgetExtension` |
| `EstonianWeather/` | App target `EstonianWeather` (SwiftUI) |
| `EstonianWeatherWidget/` | Widget extension target `EstonianWeatherWidgetExtension` |
| `EstonianWeatherTests/` | Test target `EstonianWeatherTests` (Swift Testing) |
| `Resources/` | `Localizable.xcstrings`, test plan `EstonianWeather.xctestplan`, `Settings.bundle` |
| `ReleaseRelatedInfo/` | README images, icon sources, App Store screenshots |
| `fastlane/` | Fastfile and App Store metadata (`fastlane/metadata/`) |
| `.github/workflows/ci.yml` | CI |
| `.swiftformat` | Formatting rules |

## Build, test, format

Run from the repo root. CI runs the lint and test commands; the build command is a quicker local check.

```sh
swiftformat --lint .
```

```sh
xcodebuild build -project EstonianWeather.xcodeproj -scheme EstonianWeather -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild test -project EstonianWeather.xcodeproj -scheme EstonianWeather -testPlan EstonianWeather -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=latest' CODE_SIGNING_ALLOWED=NO
```

CI runs the same test command but picks the newest iPhone simulator available on the runner instead of `iPhone 18 Pro`. Locally, use any installed iPhone simulator.

To fix formatting, run `swiftformat .` and commit the result separately from other changes.

## CI

`.github/workflows/ci.yml` runs on every pull request and on pushes to `master`. It has two jobs:

- `lint` (`macos-latest`): installs SwiftFormat with Homebrew and runs `swiftformat --lint .`
- `build-and-test` (GitHub's `xcode-27` image): selects Xcode 27.2 with `xcode-select`, picks the newest available iPhone simulator, and runs the `xcodebuild test` command above (which also builds the app and widget)

## App

- Targets: app `EstonianWeather` and widget extension `EstonianWeatherWidgetExtension`.
- Bundle id: `com.shiaulis.EstonianWeather` (widget: `com.shiaulis.EstonianWeather.EstonianWeatherWidget`). App Store id: 1534551991.
- The app is localized in English and Estonian only. Strings live in `Resources/Localizable.xcstrings`. Do not add other languages.
- App Store metadata lives in `fastlane/metadata/` and is `en-US` only, because App Store Connect has no Estonian listing. Do not add an `et` metadata folder.
- Signing is automatic. The Apple Developer membership is lapsed, so distribution signing, archiving for the App Store and uploads are not possible until it is renewed. Xcode Cloud (TestFlight) is planned after the renewal.

## Conventions

- Swift 6 language mode with strict concurrency. Fix concurrency warnings; do not silence them.
- Write new tests with Swift Testing (`import Testing`), not XCTest.
- `.swiftformat` is the style authority. Do not add SwiftLint or Periphery.
- No new third-party dependencies without the owner's approval.
- Keep changes scoped to the ticket. No drive-by refactoring.
- Never commit secrets or personal data (API keys, Apple ID, private emails, phone numbers).

## Dependencies and releases

- Swift packages, resolved by Xcode: `weatherCore` → `networking` (both owned), plus third-party `SWXMLHash` and `swift-http-types`.
- A change to an owned package flows like this: merge its PR → the owner or coordinator tags `X.Y.Z` → bump the version in this project.
- Tags are plain `X.Y.Z`, no `v` prefix. Releases so far: 1.2.0, 1.3.1, 1.4.0, 2.0.0, 2.1.0. Version 3.0 is in progress.
- Release tooling is fastlane via Bundler:

  ```sh
  bundle install
  bundle exec fastlane metadata
  ```

  `fastlane metadata` uploads `fastlane/metadata/` to App Store Connect. It authenticates with `APP_STORE_CONNECT_API_KEY_KEY_ID`, `APP_STORE_CONNECT_API_KEY_ISSUER_ID` and `APP_STORE_CONNECT_API_KEY_KEY` from the environment. Uploads fail until the membership is renewed.

## Git workflow

- One branch per Linear ticket in the EES team, named with the ticket's git branch name.
- Open a PR against `master`. The owner reviews and merges on GitHub.
- Never push to `master`. Never create or push tags.
