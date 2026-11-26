# AGENTS.md

## Overview

Eesti Ilm is an iOS weather app for Estonia. It shows the forecast from the Estonian Environment Agency's weather service ([ilmateenistus.ee](https://www.ilmateenistus.ee)) in a forecast list and a home-screen widget. Everything lives in this repo: the app and widget share the `WeatherCore` dynamic framework (forecast fetching and XML parsing), which depends on the `Networking` dynamic framework (HTTP layer). Both were separate repos (weatherCore, networking) and were merged into this repository with their history. The project is being revived: version 2.3 is in development and the app is temporarily not on the App Store.

## Requirements

- Xcode 27.2 or later, Swift 6 language mode. The project uses Xcode's JSON project format (`project.xcproj`), which Xcode 26 and earlier cannot open
- Minimum deployment target: iOS 27.0
- SwiftFormat from Homebrew: `brew install swiftformat`
- For releases only: Ruby (version in `.ruby-version`) and Bundler

## Repo layout

| Path | Contents |
| --- | --- |
| `EstonianWeather.xcodeproj` | Xcode project (`project.xcproj`, JSON format). Schemes: `EstonianWeather`, `EstonianWeatherWidgetExtension` |
| `EstonianWeather/` | App target `EstonianWeather` (SwiftUI) |
| `EstonianWeatherWidget/` | Widget extension target `EstonianWeatherWidgetExtension` |
| `EstonianWeatherTests/` | App unit test target `EstonianWeatherTests` (Swift Testing) |
| `Networking/` | Dynamic framework target `Networking` (`Endpoint`, `URLSessionNetworkClient`, `Response`, built on `swift-http-types`) |
| `NetworkingTests/` | Unit test target `NetworkingTests` (Swift Testing) |
| `WeatherCore/` | Dynamic framework target `WeatherCore` (`WeatherService`, XML parsing via `SWXMLHash`; depends on `Networking`) |
| `WeatherCoreTests/` | Unit test target `WeatherCoreTests` (Swift Testing) |
| `Resources/` | `Localizable.xcstrings`, test plan `EstonianWeather.xctestplan`, `Settings.bundle` |
| `ReleaseRelatedInfo/` | README images, icon sources, App Store screenshots |
| `fastlane/` | Fastfile (lanes `metadata`, `screenshots`, `beta`), App Store metadata (`fastlane/metadata/`) and screenshots (`fastlane/screenshots/`) |
| `.github/workflows/ci.yml` | CI |
| `.github/workflows/testflight.yml` | Manual TestFlight upload |
| `.github/dependabot.yml` | Dependabot version updates |
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

The `EstonianWeather` test plan runs `EstonianWeatherTests`, `NetworkingTests`, and `WeatherCoreTests`. `WeatherCoreTests` calls the live ilmateenistus.ee feed, so it needs network access.

To fix formatting, run `swiftformat .` and commit the result separately from other changes.

## CI

`.github/workflows/ci.yml` runs on every pull request and on pushes to `master`. It has two jobs:

- `lint` (`macos-latest`): installs `actionlint` with Homebrew to lint workflows, downloads a pinned SwiftFormat release, and runs `swiftformat --lint .` over the whole repo
- `build-and-test` (GitHub's `xcode-27` image): selects Xcode 27.2 with `xcode-select`, picks the newest available iPhone simulator, and runs the `xcodebuild test` command above (which builds the app, widget, and frameworks, and runs all three test bundles)

`.github/workflows/testflight.yml` runs only on `workflow_dispatch`, never on pushes or pull requests. It has one job, `upload` (`xcode-27` image): selects Xcode 27.2, sets up Ruby from `.ruby-version` with Bundler caching, and runs `bundle exec fastlane beta` with the `APP_STORE_CONNECT_API_KEY_KEY_ID`, `APP_STORE_CONNECT_API_KEY_ISSUER_ID` and `APP_STORE_CONNECT_API_KEY_KEY` secrets. The job declares `environment: testflight`: the secrets are stored in that GitHub environment (not as repository secrets), and the environment allows only the `master` branch, so the workflow can only run from `master`. Runs need no approval: only accounts with write access can start the workflow. Runs are serialized (`concurrency: testflight`). Agents never trigger this workflow unless the owner asks.

## App

- Targets: app `EstonianWeather`, widget extension `EstonianWeatherWidgetExtension`, dynamic frameworks `Networking` and `WeatherCore`, and unit test bundles `EstonianWeatherTests`, `NetworkingTests`, and `WeatherCoreTests`.
- Embedding: the app links and embeds `Networking.framework` and `WeatherCore.framework` once in `EstonianWeather.app/Frameworks/`. The widget extension links `WeatherCore` (and `Networking` transitively) and loads them from the host app via `@executable_path/../../Frameworks` without embedding a second copy.
- Bundle id: `com.shiaulis.EstonianWeather` (widget: `com.shiaulis.EstonianWeather.EstonianWeatherWidget`, frameworks: `com.shiaulis.Networking`, `com.shiaulis.WeatherCore`). App Store id: 1534551991.
- The project file is `EstonianWeather.xcodeproj/project.xcproj`, Xcode's JSON project format (there is no `project.pbxproj`). Edit it directly: files, targets, build settings and packages are listed by name and path. It is JSON5-like (comments, trailing commas), so strict JSON tools such as `jq` cannot parse it. Keep the existing `id` values of targets and products: the shared schemes and `Resources/EstonianWeather.xctestplan` reference them. Do not convert the project back to `project.pbxproj`.
- Signing is automatic. TestFlight builds upload only from GitHub Actions, through the `TestFlight` workflow (`testflight.yml`) and the `beta` lane (EES-85), using cloud-managed signing: no certificates, profiles or `match` in the repo. Xcode Cloud is not used. The first App Store submission is tracked in EES-20.

## Localization

- Languages: English (`en`, source language) and Estonian (`et`) only. Do not add other languages. Only the app and widget interfaces are translated.
- String Catalog: `Resources/Localizable.xcstrings`, included in both the `EstonianWeather` and `EstonianWeatherWidgetExtension` targets.
- String style:
  - Default: use the English text as the key so Xcode extracts it automatically (e.g. `Text("Contact me")`, `String(localized: "Loading")`).
  - Long texts only (paragraphs such as the About me bio or data-source disclaimer): use a hand-picked manual key in `Resources/Localizable.xcstrings` with Xcode's generated symbol (`STRING_CATALOG_GENERATE_SYMBOLS = YES`), e.g. `Text(.aboutMeDescription)`.
  - Use `Text(verbatim: ...)` for non-translatable placeholder text or literals that should not be extracted.
  - Do not add SwiftGen, R.swift, or `.strings` files.
- `Resources/Settings.bundle` is included in the `EstonianWeather` app target only (shows Version and Build in iOS Settings) and stays English only (iOS requires a `.strings` file there).
- App Store metadata lives in `fastlane/metadata/` and is `en-US` only, because App Store Connect has no Estonian listing. Do not add an `et` metadata folder.

## Conventions

- Swift 6 language mode with strict concurrency. Fix concurrency warnings; do not silence them.
- Write new tests with Swift Testing (`import Testing`), not XCTest.
- `.swiftformat` is the style authority. Do not add SwiftLint or Periphery.
- No new third-party dependencies without the owner's approval.
- Keep changes scoped to the ticket. No drive-by refactoring.
- Never commit secrets or personal data (API keys, Apple ID, private emails, phone numbers).
- Never mention the owner's Apple Developer account, membership or its status in files, commit messages, PR descriptions or comments.

## Dependencies and releases

- `Networking` and `WeatherCore` are framework targets inside `EstonianWeather.xcodeproj`. They are not versioned or tagged separately: change them in the same PR as the app code that needs the change.
- Third-party packages, resolved by Swift Package Manager as remote dependencies in `EstonianWeather.xcodeproj`: `SWXMLHash` (`WeatherCore`) and `swift-http-types` (`Networking`, `NetworkingTests`). Pins are in `EstonianWeather.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
- Dependabot version updates are configured in `.github/dependabot.yml`: monthly, one grouped PR per ecosystem, for `github-actions` (keeps the SHA pins and their version comments in the workflow files) and `bundler` (`Gemfile`, `Gemfile.lock`). Dependabot PRs open against `master` and go through the same required checks and `@Shiaulis` review as any other PR. They are exempt from the PR template (Dependabot writes its own PR body and cannot fill in template sections), so do not edit their descriptions to match it.
- Dependabot cannot see the Swift packages: its `swift` ecosystem only reads `Package.swift`, and the packages are declared in the Xcode project. Check `SWXMLHash` and `swift-http-types` by hand (for example before each release): compare the pins in `Package.resolved` with the latest releases, then update them in a ticket-scoped PR.
- Secret scanning and push protection are enabled on the repo (GitHub settings, not files in the repo).
- App release tags are plain `X.Y.Z`, no `v` prefix. Releases so far: 1.2.0, 1.3.1, 1.4.0, 2.0.0, 2.1.0, 2.1.1, 2.2.0. Version 2.3 is in progress.
- Release tooling is fastlane via Bundler:

  ```sh
  bundle install
  bundle exec fastlane metadata
  bundle exec fastlane screenshots
  ```

  `fastlane metadata` uploads `fastlane/metadata/` to App Store Connect. It authenticates with `APP_STORE_CONNECT_API_KEY_KEY_ID`, `APP_STORE_CONNECT_API_KEY_ISSUER_ID` and `APP_STORE_CONNECT_API_KEY_KEY` from the environment.

  `fastlane screenshots` uploads `fastlane/screenshots/en-US/` (iPhone 6.9" 1320x2868 and iPad 13" 2064x2752, JPEG, plain screenshots without captions) and replaces the existing ones. `fastlane beta` archives the `EstonianWeather` scheme (app and widget, `Release`) and uploads it to TestFlight without waiting for processing. It uses the same three environment variables. It signs with Xcode automatic signing and cloud-managed certificates: it writes the API key to a temporary `.p8` file, passes `-allowProvisioningUpdates` with `-authenticationKeyPath`, `-authenticationKeyID` and `-authenticationKeyIssuerID` to `xcodebuild`, and deletes the file when the build ends. The uploaded version and build number are the project's own `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` (read with `xcodebuild -showBuildSettings`, no override), so each new TestFlight upload needs a PR that raises `CURRENT_PROJECT_VERSION` first (app, widget and frameworks stay in sync). Before archiving, the lane checks the App Store Connect builds list (which includes expired builds) and fails with a message if that version and build number already exist. When `GITHUB_STEP_SUMMARY` is set, the lane appends the uploaded version and build (for example `2.3 (57)`) to it. The API key needs the Admin role, because cloud-managed signing has to create the distribution certificate. The lane calls `xcodebuild archive` and `xcodebuild -exportArchive` directly instead of fastlane's `build_app`, because `build_app` reads the project through the `xcodeproj` gem, which cannot open the JSON project format. It uploads the exported `.ipa` from `build/` (git-ignored). The lane runs only from the `TestFlight` workflow, not locally.

  Never run any of these lanes, or the `TestFlight` workflow, unless the owner asks.

## Git workflow

- One branch per Linear ticket in the EES team, named with the ticket's git branch name.
- Coding agents commit, push, open PRs, and comment on GitHub as the `telbin-bot` machine account (never approve or directly merge PRs).
- Open agent PRs against `master` as a draft (`gh pr create --draft`) while iterating on CI or review feedback; mark ready (`gh pr ready`) once checks pass and comments are resolved so `@Shiaulis` gets a single review request via `CODEOWNERS`.
- Enabling squash auto-merge (`gh pr merge --auto --squash`) is allowed only before `@Shiaulis` has approved (when `Protect master` requires `@Shiaulis`'s approval, so GitHub cannot merge immediately); never run `gh pr merge` on an already-approved PR.
- Every PR, human or agent, follows `.github/pull_request_template.md` exactly: same sections, same order, no other sections. Agents fill them like this:
  - Ticket: the Linear link.
  - Motivation: why the change is needed, the problem or bug, in 1-2 sentences.
  - Explanation: why it was done this way, plus trade-offs, in 1-3 sentences.
  - AI: the agent, model and workflow, in 1 sentence.
  - Testing: only what needs testing on a device, no commands or CI results; if nothing, write "Testing on device not needed."
- Dependabot PRs are exempt from the template and keep their own description.
- The PR description contains only the template: CodeRabbit's summary is disabled (`high_level_summary: false` in `.coderabbit.yaml`), so it never edits the description.
- PR descriptions do not end with the "Generated with Claude Code" line.
- Never push to `master`. Never create or push tags.
