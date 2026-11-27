# AGENTS.md

## Overview

Eesti Ilm is an iOS weather app for Estonia showing [ilmateenistus.ee](https://www.ilmateenistus.ee) forecasts in a list and home-screen widget (v2.3 in development). Both share the `WeatherCore` dynamic framework (fetching, XML parsing), which depends on `Networking` (HTTP layer).

## Requirements

- Xcode 27.2+, Swift 6 language mode, minimum deployment target iOS 27.0.
- `project.xcproj` uses Xcode's JSON project format (Xcode 26 and earlier cannot open it).
- SwiftFormat (`brew install swiftformat`). Releases only: Ruby (`.ruby-version`) and Bundler.

## Repo layout

| Path | Contents |
| --- | --- |
| `EstonianWeather.xcodeproj` | `project.xcproj` (JSON); schemes `EstonianWeather`, `EstonianWeatherWidgetExtension` |
| `EstonianWeather/` | App target (programmatic UIKit, no storyboards, scene lifecycle) |
| `EstonianWeatherWidget/` | WidgetKit extension (SwiftUI) |
| `Networking/`, `WeatherCore/` | Dynamic frameworks (`swift-http-types`; `SWXMLHash` + `Networking`) |
| `EstonianWeatherTests/`, `NetworkingTests/`, `WeatherCoreTests/` | Unit test targets (Swift Testing) |
| `Resources/` | `Localizable.xcstrings`, `EstonianWeather.xctestplan`, `Settings.bundle` |
| `docs/localization.md` | Localization, String Catalog, and Crowdin rules |
| `ReleaseRelatedInfo/` | README images, icon sources, `DesignBook/index.html` |
| `fastlane/` | `Fastfile` (`metadata`, `screenshots`, `beta`), `metadata/`, `screenshots/`, `testflight_notes.txt` |
| `.github/`, `.swiftformat`, `crowdin.yml` | CI (`ci.yml`), TestFlight (`testflight.yml`), Dependabot, formatting, Crowdin |

## Build, test, format

Run from the repo root.

```sh
swiftformat --lint .
```

```sh
xcodebuild build -project EstonianWeather.xcodeproj -scheme EstonianWeather -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

```sh
xcodebuild test -project EstonianWeather.xcodeproj -scheme EstonianWeather -testPlan EstonianWeather -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=latest' CODE_SIGNING_ALLOWED=NO
```

- Locally use any installed iPhone simulator. CI (`.github/workflows/ci.yml`) runs `lint` (`actionlint`, `swiftformat --lint .`) and `build-and-test` (`xcode-27` image, Xcode 27.2, newest available iPhone simulator).
- The `EstonianWeather` test plan runs all three test bundles; `WeatherCoreTests` hits live `ilmateenistus.ee` (needs network).
- Fix formatting with `swiftformat .` and commit it separately from other changes.

## App

- **UI**: `EstonianWeather` is programmatic UIKit-only (no storyboards; `AppDelegate`/`SceneDelegate`, partial `EstonianWeather/Info.plist`), single-window only (`UIApplicationSupportsMultipleScenes` off). `EstonianWeatherWidgetExtension` uses SwiftUI (WidgetKit requirement).
- **Embedding**: App embeds `Networking.framework` and `WeatherCore.framework` once in `EstonianWeather.app/Frameworks/`; widget links `WeatherCore` (and `Networking` transitively) and loads both via `@executable_path/../../Frameworks` without embedding copies.
- **Bundle IDs**: `com.shiaulis.EstonianWeather`, `com.shiaulis.EstonianWeather.EstonianWeatherWidget`, `com.shiaulis.Networking`, `com.shiaulis.WeatherCore`.
- **Xcode project**: Edit `EstonianWeather.xcodeproj/project.xcproj` directly (JSON5-like: comments and trailing commas — do not parse with strict JSON tools like `jq`). Preserve target and product `id` values (referenced by shared schemes and `Resources/EstonianWeather.xctestplan`). Never convert back to `project.pbxproj`.
- **Signing**: Automatic (cloud-managed in CI); never add certificates, profiles, `match`, or Xcode Cloud.

## Conventions

- Swift 6 with strict concurrency. Fix concurrency warnings; never silence them.
- Write new tests with Swift Testing (`import Testing`), not XCTest.
- `.swiftformat` is the style authority. Never add SwiftLint or Periphery.
- Never add third-party dependencies without owner approval.
- Keep changes scoped to the ticket; no drive-by refactoring.
- Never commit secrets or personal data (API keys, Apple ID, private emails, phone numbers).
- Never mention the owner's Apple Developer account, membership, or its status in files, commit messages, PR descriptions, or comments.
- **Localization**: English (`en`) and Estonian (`et`) only via `Resources/Localizable.xcstrings`. Every new string needs a translator comment; never edit `et` values by hand (Crowdin syncs them). Read [docs/localization.md](docs/localization.md) before changing UI text, `Settings.bundle`, or App Store metadata.
- **Keeping `AGENTS.md` lean**: Only add cross-cutting rules needed in every session. Put task-specific guides in `docs/`, let code and workflows document their own implementation, and put owner-only processes in Linear.

## Dependencies and releases

- `Networking` and `WeatherCore` are in-repo frameworks, not versioned or tagged separately — change them in the same PR as app code.
- SPM dependencies (`SWXMLHash`, `swift-http-types`) live in `EstonianWeather.xcodeproj` (pinned in `Package.resolved`). Dependabot (`.github/dependabot.yml`) updates `github-actions` and `bundler` only.
- Each TestFlight upload requires a PR raising `CURRENT_PROJECT_VERSION` (keeping app, widget, and frameworks in sync) and updating `fastlane/testflight_notes.txt`.
- **Never run any fastlane lane (`metadata`, `screenshots`, `beta`) or trigger `.github/workflows/testflight.yml` unless the owner asks.**
- Owner-only release checklists live in the [Owner Release & Ops Runbook](https://linear.app/eestiilm/document/owner-release-and-ops-runbook-978d9997d674) in Linear.

## Ticket workflow

- Agents work in Orca. The coordinator stays in the main checkout on `master` without implementing tickets there; each agent ticket runs in its own Orca worktree via `orca orchestration worker-start` on the ticket's git branch name.
- Move the ticket to `In Progress` and assign `telbin-bot` when a worker starts (comment when useful). After PR merge, the coordinator releases the worker, removes the worktree, and moves the ticket to `Done`.
- Linear conventions (source of truth: [Linear Conventions](https://linear.app/eestiilm/document/linear-conventions-3ead849b1742)):
  - **Titles**: Plain sentence-case phrases; no colon prefixes (`App:`, `Website:`, `Widget:`, `CI:`, `Docs:`, etc.), emoji, or `You:` prefixes.
  - **Assignees**: Only manual owner-action tickets go to `andrius`; agent-executed tickets go to `telbin-bot` once started (`In Progress`, `In Review`, `Done`); leave `Backlog`/`Todo` agent tickets, parent epics, and canceled tickets unassigned.
  - **Labels**: Lowercase only; require an area label (`app`, `website`, or both) plus optional type labels (`bug`, `feature`, `improvement`, `ci/cd`, `admin`, `design`). Never create new labels without owner approval.
  - **Projects**: Version-based `<Area> <major.minor>` with no `v` prefix (e.g. `App 2.3`, `Website 1.0`); no side-projects for migrations or refactors shipping in a release.
  - **Access**: Orca CLI (`orca linear ... --workspace <id>`), or Linear MCP when explicitly connected to `EestiIlm`.

## Git workflow

- One branch per `EES` ticket, named with the ticket's git branch name, in its Orca worktree.
- Commit, push, open PRs, and comment on GitHub as `telbin-bot`. Never approve or directly merge PRs.
- Open agent PRs against `master` ready for review (no `--draft`; CodeRabbit skips drafts). `CODEOWNERS` requests `@Shiaulis`. Fix CI failures and CodeRabbit findings with follow-up commits and resolve threads.
- Enabling squash auto-merge (`gh pr merge --auto --squash`) is allowed only before `@Shiaulis` approves; never run `gh pr merge` on an already-approved PR.
- Follow `.github/pull_request_template.md` verbatim (exact sections and order, no extra sections, no "Generated with Claude Code" line). Dependabot and Crowdin (`l10n_master`) PRs are exempt — never edit their descriptions.
- Never push to `master`. Never create or push tags.
