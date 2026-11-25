# AGENTS.md

## Overview

weatherCore is a Swift package that downloads the XML forecast feed from ilmateenistus.ee (the Estonian Environment Agency's weather service) and parses it into public Swift types (`WeatherService`, `ForecastConfiguration` and related types).
It sits in the middle of the dependency chain Eesti-Ilm → weatherCore → networking: the Eesti Ilm iOS app (Shiaulis/Eesti-Ilm) depends on it, and it depends on Shiaulis/networking for HTTP requests and on SWXMLHash for XML parsing.

## Requirements

- Xcode 27.2+ (Swift 6.4.2, Swift 6 language mode). `swift-tools-version` is 6.4, the lowest version that has `.iOS(.v27)`.
- iOS 27+. macOS 26+ is declared so that `swift build` and `swift test` run on a Mac.
- SwiftFormat, installed with Homebrew: `brew install swiftformat`.
- Optional: actionlint (`brew install actionlint`) to check the workflow file.

## Repo layout

```
Package.swift                 Package manifest (platforms, dependencies)
Package.resolved              Pinned dependency versions
Sources/WeatherCore/
  WeatherService.swift        Public entry point: getForecasts(for:)
  WeatherLanguage.swift       Public enum: .english, .estonian
  ForecastConfiguration.swift Public result types
  ForecastConfigurationConverter.swift  Server models -> public types
  ForecastServerModels.swift  XML models (Forecast, DayPart, Place, Wind)
  ForecastsParser.swift       SWXMLHash-based XML parser
  NetworkClient.swift         ilmateenistus.ee endpoint via Networking
  ForecastDateFormatter.swift Date parsing and formatting
Tests/WeatherCoreTests/       Swift Testing tests
.swiftformat                  SwiftFormat config (shared with networking)
.coderabbit.yaml              CodeRabbit review config (shared with Eesti-Ilm and networking)
.github/workflows/ci.yml      CI workflow
.github/actionlint.yaml       Declares the xcode-27 runner label for actionlint
```

## Build, test, format

Run from the repo root. These are the commands CI runs:

```sh
swiftformat --lint .
swift build
swift test
```

To fix formatting: `swiftformat .`. Commit formatting-only changes separately.

`swift test` calls the live feed at `https://ilmateenistus.ee/ilma_andmed/xml/forecast.php`, so it needs network access and fails if the service is down or its XML format changes.
The test runs in CI. If it becomes flaky there, mark it with `.disabled(if:)` behind an environment variable such as `CI` and say so in the PR.

## CI

`.github/workflows/ci.yml` runs on every pull request and on every push to `master`.
Both jobs use the GitHub-hosted `xcode-27` image (macOS 27, arm64, public preview).

- **SwiftFormat lint:** `swiftformat --lint .` with the SwiftFormat preinstalled on the image (Homebrew install as fallback).
- **Build and test:** selects Xcode 27.2 with `sudo xcode-select -s /Applications/Xcode_27.2.app`, then runs `swift build` and `swift test`.

## Conventions

- Swift 6 language mode with strict concurrency. Keep public types `Sendable` where they already are.
- Write new tests with Swift Testing (`import Testing`, `@Test`), not XCTest.
- `.swiftformat` is the style authority. It is copied from Shiaulis/networking; change it there first and keep the copies identical.
- No new third-party dependencies without the owner's approval.
- Scope changes to the ticket. No drive-by refactoring.
- CodeRabbit reviews every PR using `.coderabbit.yaml`. It reads this file as its code guidelines, skips formatting comments and does not run SwiftLint.
- Never commit personal data (phone numbers, private emails, Apple ID, API keys).

## Dependencies and releases

- Owned repos: Shiaulis/Eesti-Ilm (app), Shiaulis/weatherCore (this package), Shiaulis/networking.
- Third-party: SWXMLHash (`from: "7.0.0"`).
- Tags are plain `X.Y.Z`, no `v` prefix.
- A change flows like this: merge the PR to `master` → the owner or coordinator tags `X.Y.Z` → the consumer (Eesti-Ilm) bumps its weatherCore version.
- When networking releases a new version, bump the `from:` requirement in `Package.swift` and update `Package.resolved` with `swift package update networking`.

## Git workflow

- One branch per Linear ticket in the EES team. Use the ticket's branch name (for example `andrius/ees-14`).
- Open a PR to `master`. The owner reviews and merges on GitHub.
- Never push to `master`. Never create or push tags.
- Commit messages are imperative and clear.
