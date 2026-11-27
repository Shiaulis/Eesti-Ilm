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
| `EstonianWeather/` | App target `EstonianWeather` (UIKit, programmatic, no storyboards; scene-based lifecycle) |
| `EstonianWeatherWidget/` | Widget extension target `EstonianWeatherWidgetExtension` |
| `EstonianWeatherTests/` | App unit test target `EstonianWeatherTests` (Swift Testing) |
| `Networking/` | Dynamic framework target `Networking` (`Endpoint`, `URLSessionNetworkClient`, `Response`, built on `swift-http-types`) |
| `NetworkingTests/` | Unit test target `NetworkingTests` (Swift Testing) |
| `WeatherCore/` | Dynamic framework target `WeatherCore` (`WeatherService`, XML parsing via `SWXMLHash`; depends on `Networking`) |
| `WeatherCoreTests/` | Unit test target `WeatherCoreTests` (Swift Testing) |
| `Resources/` | `Localizable.xcstrings`, test plan `EstonianWeather.xctestplan`, `Settings.bundle` |
| `ReleaseRelatedInfo/` | README images, icon sources, and the design book (`DesignBook/`: positioning, app icon and color palette; open `index.html`) |
| `fastlane/` | Fastfile (lanes `metadata`, `screenshots`, `beta`), App Store metadata (`fastlane/metadata/`), screenshots (`fastlane/screenshots/`) and TestFlight What to Test notes (`fastlane/testflight_notes.txt`) |
| `.github/workflows/ci.yml` | CI |
| `.github/workflows/testflight.yml` | Manual TestFlight upload and external distribution |
| `.github/dependabot.yml` | Dependabot version updates |
| `.swiftformat` | Formatting rules |
| `crowdin.yml` | Crowdin configuration for `Resources/Localizable.xcstrings` (see Localization) |

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

`.github/workflows/testflight.yml` runs only on `workflow_dispatch`, never on pushes or pull requests. It has one job, `upload` (`xcode-27` image, 90 minute timeout): checks out the full history (`fetch-depth: 0`), selects Xcode 27.2, sets up Ruby from `.ruby-version` with Bundler caching, finds the commit (`headSha`) of the newest successful run of this workflow through the GitHub API (`GITHUB_TOKEN` with `actions: read`), and runs `bundle exec fastlane beta` with that commit as `TESTFLIGHT_LAST_UPLOAD_SHA` and the `APP_STORE_CONNECT_API_KEY_KEY_ID`, `APP_STORE_CONNECT_API_KEY_ISSUER_ID` and `APP_STORE_CONNECT_API_KEY_KEY` secrets. The job declares `environment: testflight`: the secrets are stored in that GitHub environment (not as repository secrets), and the environment allows only the `master` branch, so the workflow can only run from `master`. Runs need no approval: only accounts with write access can start the workflow. Runs are serialized (`concurrency: testflight`). Agents never trigger this workflow unless the owner asks.

## App

- Targets: app `EstonianWeather`, widget extension `EstonianWeatherWidgetExtension`, dynamic frameworks `Networking` and `WeatherCore`, and unit test bundles `EstonianWeatherTests`, `NetworkingTests`, and `WeatherCoreTests`.
- UI frameworks: `EstonianWeather` is UIKit-only (programmatic, no storyboards; `AppDelegate`/`SceneDelegate` lifecycle), with `EstonianWeather/Info.plist` as a partial Info.plist merged with the generated one to declare the scene manifest. The app has one window on every platform (`UIApplicationSupportsMultipleScenes` is off): a second window would only show the same forecast and settings again, with its own forecast request. `EstonianWeatherWidgetExtension` uses SwiftUI because WidgetKit requires it.
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
- String rules:
  - Every new string gets a translator comment, in code (`String(localized:comment:)`, `Text(_:comment:)`) or in the catalog. The comment names the UI element and explains each placeholder. Translators see it as context.
  - Do not build sentences by joining translated pieces. Use one string with placeholders, so translators can reorder the words.
  - Plurals are variations in the String Catalog, not `if count == 1` in code.
  - Text that is not translated (numbers, temperatures, dates, names) uses `Text(verbatim:)` or formatted values (`FormatStyle`), not catalog strings.
  - Use plain `String(localized:)` and `Text`. Use `LocalizedStringResource` only where an API requires it, such as App Intents.
  - Weather phenomenon names come from the feed in English. Show them through `WeatherPhenomenonIcon.localizedName(for:)`, which looks them up in the catalog.
- `StringCatalogTests` fails when a translatable string in `Resources/Localizable.xcstrings` has no translator comment, or has an Estonian translation with an empty value. A missing Estonian translation is allowed (any state counts when present).
- Translation workflow (Crowdin, connected through its GitHub integration, configured in the Crowdin project; `crowdin.yml` describes the String Catalog for it):
  - New strings are added in Xcode with English text and a translator comment only. They reach Crowdin when they land on `master`.
  - Estonian is translated and approved in Crowdin. Do not add or edit Estonian values in `Resources/Localizable.xcstrings` by hand: Crowdin does not import them, and its next sync may replace or drop them.
  - Crowdin's PR adds the Estonian values after translation. Until then the app shows English.
  - Before a release, check in Crowdin that Estonian is fully translated and approved.
  - Crowdin opens or updates one PR from `l10n_master` with new translations. It is merged like any other PR once CI passes; the branch is deleted on merge and Crowdin recreates it.
  - Crowdin has no "needs review" state: its PRs mark imported translations as `translated`. Review status (approved or not) lives in Crowdin.
  - Crowdin's PRs are exempt from the PR template (Crowdin writes its own PR body and cannot fill in template sections), so do not edit their descriptions to match it.
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
- Dependabot version updates are configured in `.github/dependabot.yml`: monthly, one grouped PR per ecosystem, for `github-actions` (keeps the SHA pins and their version comments in the workflow files) and `bundler` (`Gemfile`, `Gemfile.lock`). Dependabot PRs open against `master` and go through the same required checks and `@Shiaulis` review as any other PR. They are exempt from the PR template (Dependabot writes its own PR body and cannot fill in template sections), so do not edit their descriptions to match it. Crowdin's PRs (from `l10n_master`) are exempt for the same reason (see Localization).
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

  `fastlane screenshots` uploads `fastlane/screenshots/en-US/` (iPhone 6.9" 1320x2868 and iPad 13" 2064x2752, JPEG, plain screenshots without captions) and replaces the existing ones. `fastlane beta` archives the `EstonianWeather` scheme (app and widget, `Release`), uploads it to TestFlight, waits for Apple's processing, sets the build's What to Test notes, submits it for Beta App Review (TestFlight review only, never App Store review) and adds it to the external TestFlight group `Testers`, notifying its testers. Internal testers get every build as before. It uses the same three environment variables. It signs with Xcode automatic signing and cloud-managed certificates: it writes the API key to a temporary `.p8` file, passes `-allowProvisioningUpdates` with `-authenticationKeyPath`, `-authenticationKeyID` and `-authenticationKeyIssuerID` to `xcodebuild`, and deletes the file when the build ends. The uploaded version and build number are the project's own `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` (read with `xcodebuild -showBuildSettings`, no override), so each new TestFlight upload needs a PR that raises `CURRENT_PROJECT_VERSION` first (app, widget and frameworks stay in sync). Before archiving, the lane checks the App Store Connect builds list (which includes expired builds) and fails with a message if that version and build number already exist. It also fails before archiving if App Store Connect has no group named `Testers` or it is an internal group. The beta description, feedback email and review contact come from TestFlight's Test Information in App Store Connect: the lane passes no review or contact data, and none is kept in the repo. What to Test notes:

  - The PR that raises `CURRENT_PROJECT_VERSION` also updates `fastlane/testflight_notes.txt` with notes for testers.
  - If that file changed since `TESTFLIGHT_LAST_UPLOAD_SHA`, or that variable is empty or its commit is not reachable from `HEAD`, the lane uses the file as is.
  - Otherwise it uses the commit subjects since that commit (`git log --no-merges`), one `- ` bullet each, without the `EES-123: ` prefix and the ` (#123)` suffix.
  - Notes over TestFlight's 4000-byte limit are truncated at a line break. Empty notes fail the lane before archiving.

  When `GITHUB_STEP_SUMMARY` is set, the lane appends the uploaded version and build (for example `2.3 (57)`) and the notes source (the file or the commit subjects) to it. The API key needs the Admin role, because cloud-managed signing has to create the distribution certificate. The lane calls `xcodebuild archive` and `xcodebuild -exportArchive` directly instead of fastlane's `build_app`, because `build_app` reads the project through the `xcodeproj` gem, which cannot open the JSON project format. It uploads the exported `.ipa` from `build/` (git-ignored). The lane runs only from the `TestFlight` workflow, not locally.

  Never run any of these lanes, or the `TestFlight` workflow, unless the owner asks.

## Ticket workflow

- Agents work in Orca. The coordinator agent works in the main checkout on `master` and does not implement tickets there.
- For each agent-executed Linear ticket, the coordinator starts a separate worker in its own Orca worktree with `orca orchestration worker-start`. The worker's branch is the ticket's git branch name.
- The ticket reflects the work: it moves to In Progress and is assigned to `telbin-bot` when the worker starts. Agents may comment on the ticket when useful (worker and workspace, progress, decisions, PR link, blockers).
- When the ticket is done (PR merged), the coordinator releases the worker, removes the Orca workspace, and moves the ticket to Done.
- Linear conventions (full details in the [Linear Conventions](https://linear.app/eestiilm/document/linear-conventions-3ead849b1742) document in Linear, which is the single source of truth):
  - Titles: plain sentence-case phrases with no colon prefixes (`App:`, `Website:`, `Widget:`, `CI:`, `Docs:`, etc.) and no emoji or `You:` prefixes.
  - Assignees: assign only manual owner-action tickets to the owner (`andrius`); assign agent-executed tickets to `telbin-bot` once work starts (`In Progress`, `In Review`, and `Done`); leave agent-executable tickets in `Backlog` or `Todo`, parent epics, and canceled tickets unassigned.
  - Labels: lowercase only; every ticket requires an area label (`app`, `website`, or both for shared brand/design work) plus optional type labels (`bug`, `feature`, `improvement`, `ci/cd`, `admin`, `design`). Do not create new labels without owner approval.
  - Projects: version-based `<Area> <major.minor>` with no `v` prefix (for example `App 2.3`, `Website 1.0`); do not create separate side-projects for migrations or refactors that ship inside a release.
  - Access: reach Linear through the Orca CLI (`orca linear ... --workspace <id>`), or the Linear MCP plugin when explicitly connected to the `EestiIlm` workspace.

## Git workflow

- One branch per Linear ticket in the EES team, named with the ticket's git branch name and worked on in that ticket's Orca worktree (see Ticket workflow).
- Coding agents commit, push, open PRs, and comment on GitHub as the `telbin-bot` machine account (never approve or directly merge PRs).
- Open agent PRs against `master` ready for review (no `--draft`; CodeRabbit skips drafts). `CODEOWNERS` requests `@Shiaulis`'s review when the PR opens. Fix CI failures and CodeRabbit findings with follow-up commits on the same PR and resolve the threads.
- Enabling squash auto-merge (`gh pr merge --auto --squash`) is allowed only before `@Shiaulis` has approved (when `Protect master` requires `@Shiaulis`'s approval, so GitHub cannot merge immediately); never run `gh pr merge` on an already-approved PR.
- Every PR, human or agent, follows `.github/pull_request_template.md` exactly: same sections, same order, no other sections. Agents fill them like this:
  - Ticket: the Linear link.
  - Motivation: why the change is needed, the problem or bug, in 1-2 sentences.
  - Explanation: why it was done this way, plus trade-offs, in 1-3 sentences.
  - AI: the agent, model and workflow, in 1 sentence.
  - Testing: only what needs testing on a device, no commands or CI results; if nothing, write "Testing on device not needed."
- Dependabot PRs and Crowdin PRs (from `l10n_master`) are exempt from the template and keep their own description: they write their own and cannot fill in template sections.
- The PR description contains only the template: CodeRabbit's summary is disabled (`high_level_summary: false` in `.coderabbit.yaml`), so it never edits the description.
- PR descriptions do not end with the "Generated with Claude Code" line.
- Never push to `master`. Never create or push tags.
