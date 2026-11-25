# AGENTS.md

## Overview
`networking` (GitHub: `Shiaulis/networking`) is a small Swift package, product `Networking`, that turns an `Endpoint` description into an `HTTPRequest` (from `apple/swift-http-types`) and executes it with `URLSession`. It sits at the bottom of the dependency chain Eesti-Ilm (iOS app) → weatherCore → networking: weatherCore depends on it, and the Eesti-Ilm app depends on weatherCore. Changes here reach the app only after a new tag of this package and a version bump in weatherCore.

## Requirements
- Xcode 27.2+ (Swift 6.4 toolchain; the manifest uses `swift-tools-version: 6.4`, the first version with `.iOS(.v27)`)
- Platforms: iOS 27.0+, macOS 26.0+ (macOS is declared so `swift test` runs on a Mac host)
- SwiftFormat: `brew install swiftformat`
- Optional: actionlint for workflow edits: `brew install actionlint`

## Repo layout
```
Package.swift                         Manifest: platforms, product, swift-http-types dependency
Package.resolved                      Pinned dependency versions (committed)
Sources/Networking/
  Endpoint.swift                      Endpoint protocol, EndpointScheme, HTTPMethod
  URLSessionNetworkClient.swift       Public client: Endpoint → HTTPRequest → Response
  Response.swift                      Response (endpoint, data, status)
  NetworkConnectionProvider.swift     Internal seam over URLSession, used for test mocks
Tests/NetworkingTests/                Swift Testing suites (EndpointTests, ResponseTests)
  Helpers/                            MockNetworkConnectionProvider, OpenWeatherMapEndpoint
.swiftformat                          SwiftFormat config (style authority)
.github/workflows/ci.yml              CI workflow
.coderabbit.yaml                      CodeRabbit PR review config (follows this file, SwiftLint off)
```

## Build, test, format
Run from the repo root. These are the same commands CI runs.
```sh
sudo xcode-select -s /Applications/Xcode_27.2.app   # only if Xcode 27.2 is not already selected
swiftformat --lint .
swift build
swift test
```
To fix formatting: `swiftformat .`. Commit formatting-only changes separately from code changes.

## CI
`.github/workflows/ci.yml` runs on every pull request and on every push to `master`, on the GitHub-hosted `xcode-27` image (macOS 27, arm64).
- Job `lint`: `swiftformat --lint .` with the SwiftFormat preinstalled on the image.
- Job `build-and-test`: selects Xcode 27.2 with `sudo xcode-select -s /Applications/Xcode_27.2.app`, then `swift build` and `swift test`.

No setup-swift action is used; the toolchain comes from the selected Xcode. If the image's Xcode path changes, check the `actions/runner-images` README and update the workflow.

## Conventions
- Swift 6 language mode with strict concurrency. Public types are `Sendable`; keep new API concurrency-safe without `@unchecked` or `nonisolated(unsafe)` unless there is no alternative.
- Write new tests with Swift Testing (`import Testing`, `@Test`, `#expect`, `#require`), not XCTest.
- `.swiftformat` is the style authority. Do not add SwiftLint or other linters.
- No new third-party dependencies without the owner's approval. The only dependency today is `apple/swift-http-types`.
- Keep the public API small. Changing or removing public API, or raising a minimum platform, is a breaking change and needs a minor version bump while the package is below 1.0.

## Dependencies and releases
- Owned repos in the chain: `Shiaulis/Eesti-Ilm` → `Shiaulis/weatherCore` → `Shiaulis/networking`.
- Version tags are plain `X.Y.Z` (no `v` prefix). Current line: `0.4.x` (iOS 27 minimum).
- A change flows as: PR merged to `master` → the owner or coordinator tags `X.Y.Z` → weatherCore bumps its `networking` requirement → Eesti-Ilm bumps weatherCore.
- Agents never create or push tags.

## Git workflow
- One branch per Linear ticket in the EES team, named after the ticket's `gitBranchName`.
- Open a PR to `master`. The owner reviews and merges on GitHub.
- Never push to `master`. Never create or push tags.
- Keep commits focused, with imperative commit messages.
- Do not commit personal data (phone numbers, private emails, Apple ID, API keys).
