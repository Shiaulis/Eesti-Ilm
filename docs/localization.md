# Localization

English (`en`, source) and Estonian (`et`) only — never add other languages. Only app and widget UI are translated, via `Resources/Localizable.xcstrings` (in both `EstonianWeather` and `EstonianWeatherWidgetExtension`).

## String rules

- **Keys**: Default to English text (`Text("Contact me")`, `String(localized: "Loading")`). Use manual keys with generated symbols (`STRING_CATALOG_GENERATE_SYMBOLS = YES`, e.g. `Text(.aboutMeDescription)`) for long paragraphs only.
- **Comments**: Every translatable string needs a translator comment (`String(localized:comment:)`, `Text(_:comment:)`, or in the catalog) naming the UI element and explaining placeholders. `StringCatalogTests` fails on missing comments or empty `et` values (missing `et` is allowed).
- **Formatting & plurals**: Never concatenate translated fragments — use one string with placeholders. Use catalog plural variations, not `if count == 1`. Use `Text(verbatim:)` or `FormatStyle` for non-translatable literals, numbers, temperatures, dates, and names.
- **APIs & tooling**: Use plain `String(localized:)` and `Text` (`LocalizedStringResource` only when required, e.g. App Intents). Render feed weather phenomenon names via `WeatherPhenomenonIcon.localizedName(for:)`. Never add SwiftGen, R.swift, or `.strings` files.

## Crowdin and English-only files

- Add new strings with English text and a translator comment only. **Never add or edit `et` values in `Localizable.xcstrings` by hand** — Crowdin (`crowdin.yml`) syncs `et` via `l10n_master` PRs and may overwrite manual edits.
- Crowdin PRs are exempt from `.github/pull_request_template.md`; never edit their descriptions.
- `Resources/Settings.bundle` (app target only) stays English-only. `fastlane/metadata/` is `en-US` only — never add an `et` metadata folder.
