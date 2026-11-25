# AGENTS.md

## Overview

Eesti Ilm is an iOS weather app for Estonia. It shows the forecast from the Estonian Environment Agency's weather service ([ilmateenistus.ee](https://www.ilmateenistus.ee)) in a forecast list and a home-screen widget. Everything lives in this repo: the app links the local package `WeatherCore` (forecast fetching and XML parsing), which depends on the local package `Networking` (HTTP layer). Both were separate repos (weatherCore, networking) and were moved into `Packages/` with their history. The project is being revived: version 3.0 is in development and the app is temporarily not on the App Store.

## Requirements

- Xcode 27.2 or later, Swift 6 language mode. The project uses Xcode's JSON project format (`project.xcproj`), which Xcode 26 and earlier cannot open
- Minimum deployment target: iOS 27.0
- SwiftFormat from Homebrew: `brew install swiftformat`
- For releases only: Ruby (version in `.ruby-version`) and Bundler

## Repo layout

| Path | Contents |
| --- | --- |
| `EstonianWeather.xcodeproj` | Xcode project. Project file `project.xcproj` (JSON format). Schemes: `EstonianWeather`, `EstonianWeatherWidgetExtension` |
| `EstonianWeather/` | App target `EstonianWeather` (SwiftUI) |
| `EstonianWeatherWidget/` | Widget extension target `EstonianWeatherWidgetExtension` |
| `EstonianWeatherTests/` | Test target `EstonianWeatherTests` (Swift Testing) |
| `Packages/WeatherCore/` | Local Swift package `WeatherCore`, linked by the app target. Depends on `../Networking` and SWXMLHash |
| `Packages/Networking/` | Local Swift package `Networking`. Depends on swift-http-types |
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

Packages (CI runs both commands for each package):

```sh
swift build --package-path Packages/Networking
swift test --package-path Packages/Networking
swift build --package-path Packages/WeatherCore
swift test --package-path Packages/WeatherCore
```

WeatherCore's test calls the live ilmateenistus.ee feed, so it needs network access.

To fix formatting, run `swiftformat .` and commit the result separately from other changes.

## CI

`.github/workflows/ci.yml` runs on every pull request and on pushes to `master`. It has three jobs:

- `lint` (`macos-latest`): installs SwiftFormat with Homebrew and runs `swiftformat --lint .` over the whole repo, packages included
- `packages` (GitHub's `xcode-27` image, one run per package): selects Xcode 27.2 and runs `swift build` and `swift test` for `Packages/Networking` and `Packages/WeatherCore`
- `build-and-test` (GitHub's `xcode-27` image): selects Xcode 27.2 with `xcode-select`, picks the newest available iPhone simulator, and runs the `xcodebuild test` command above (which also builds the app and widget)

## App

- Targets: app `EstonianWeather` and widget extension `EstonianWeatherWidgetExtension`.
- Bundle id: `com.shiaulis.EstonianWeather` (widget: `com.shiaulis.EstonianWeather.EstonianWeatherWidget`). App Store id: 1534551991.
- The app is localized in English and Estonian only. Strings live in `Resources/Localizable.xcstrings`. Do not add other languages.
- App Store metadata lives in `fastlane/metadata/` and is `en-US` only, because App Store Connect has no Estonian listing. Do not add an `et` metadata folder.
- The project file is `EstonianWeather.xcodeproj/project.xcproj`, Xcode's JSON project format (there is no `project.pbxproj`). Edit it directly: files, targets, build settings and packages are listed by name and path. It is JSON5-like (comments, trailing commas), so strict JSON tools such as `jq` cannot parse it. Keep the existing `id` values of targets and products: the shared schemes and `Resources/EstonianWeather.xctestplan` reference them. Do not convert the project back to `project.pbxproj`.
- Signing is automatic. The Apple Developer membership is lapsed, so distribution signing, archiving for the App Store and uploads are not possible until it is renewed. Xcode Cloud (TestFlight) is planned after the renewal.

## Conventions

- Swift 6 language mode with strict concurrency. Fix concurrency warnings; do not silence them.
- Write new tests with Swift Testing (`import Testing`), not XCTest.
- `.swiftformat` is the style authority. Do not add SwiftLint or Periphery.
- No new third-party dependencies without the owner's approval.
- Keep changes scoped to the ticket. No drive-by refactoring.
- Never commit secrets or personal data (API keys, Apple ID, private emails, phone numbers).

## Dependencies and releases

- Local packages: the app project references `Packages/WeatherCore`; WeatherCore depends on Networking with `.package(path: "../Networking")`. They are not versioned or tagged: change them in the same PR as the app code that needs the change.
- `Packages/` is interim. Both modules will become framework targets in the Xcode project (EES-30). Keep package changes minimal until then.
- Third-party packages, resolved by Swift Package Manager: `SWXMLHash` (WeatherCore) and `swift-http-types` (Networking). Pins are in `EstonianWeather.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` and in each package's `Package.resolved`.
- App release tags are plain `X.Y.Z`, no `v` prefix. Releases so far: 1.2.0, 1.3.1, 1.4.0, 2.0.0, 2.1.0. Version 3.0 is in progress.
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
