# weatherCore

[![CI](https://github.com/Shiaulis/weatherCore/actions/workflows/ci.yml/badge.svg)](https://github.com/Shiaulis/weatherCore/actions/workflows/ci.yml)

weatherCore is a Swift package that fetches the Estonian national weather forecast and turns it into Swift values.
It is the data layer of the Eesti Ilm iOS app.

- **Source:** the public XML forecast feed of [ilmateenistus.ee](https://www.ilmateenistus.ee), the weather service of the Estonian Environment Agency.
- **Networking:** requests go through [Shiaulis/networking](https://github.com/Shiaulis/networking).
- **Parsing:** the XML is parsed with [SWXMLHash](https://github.com/drmohundro/SWXMLHash).
- **Languages:** forecasts are available in English and Estonian.

The feed covers the next few days (usually four).
Each day has a night and a day part, with a phenomenon (for example "Light snow shower"), a temperature range and a text description.
A day part can also include per-place forecasts, wind forecasts, and sea and Lake Peipus conditions.

## Requirements

- Xcode 27.2 or later (Swift 6.4, Swift 6 language mode)
- iOS 27 or later
- macOS 26 or later (used for `swift build` and `swift test` on a Mac)

## Installation

Add the package to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Shiaulis/weatherCore.git", from: "0.3.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "WeatherCore", package: "weatherCore"),
        ]
    ),
]
```

In Xcode, choose **File > Add Package Dependencies…**, enter `https://github.com/Shiaulis/weatherCore.git`, and add the `WeatherCore` library to your target.

## Usage

```swift
import WeatherCore

let service = WeatherService()
let forecasts = try await service.getForecasts(for: .english)

for forecast in forecasts {
    print(forecast.date.formatted(date: .abbreviated, time: .omitted))
    print("Night:", forecast.night.phenomenon, forecast.night.temperatureRange.formattedRange)
    print("Day:", forecast.day.phenomenon, forecast.day.temperatureRange.formattedRange)
    print(forecast.day.description)
}
```

`getForecasts(for:)` makes a network request each time it is called and throws if the request or the parsing fails.
Pass `.estonian` for forecasts in Estonian.

### Public types

| Type | What it holds |
| --- | --- |
| `WeatherService` | Entry point. `getForecasts(for:)` returns `[ForecastConfiguration]`. |
| `WeatherLanguage` | `.english` or `.estonian`. |
| `ForecastConfiguration` | One day: `date`, `night` and `day`. |
| `DayPartConfiguration` | `phenomenon`, `temperatureRange`, `description`, `places`, `winds`, `seaCondition`, `lakeCondition`. |
| `PlaceConfiguration` | Forecast for a named place: `name`, `phenomenon`, optional `temperatureRange`. |
| `WindConfiguration` | `name`, `direction`, `speedRange`, optional `gustDescription`. |
| `TemperatureRange` | `minimum` and `maximum` in °C, plus `formattedRange`, `average`, `span`. |
| `SpeedRange` | `minimum` and `maximum` in m/s, plus `formattedRange`, `average`. |

## Development

```sh
swift build
swift test
swiftformat --lint .
```

`swift test` calls the live ilmateenistus.ee feed, so it needs network access.
See [AGENTS.md](../../AGENTS.md) for the repo layout, conventions and release flow.
