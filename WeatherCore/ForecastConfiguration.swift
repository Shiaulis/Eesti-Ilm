//
//  ForecastConfiguration.swift
//  WeatherCore
//
//  Created by Andrius Shiaulis on 06.07.2025.
//

import Foundation

// MARK: - Main Configuration

public struct ForecastConfiguration: Sendable, Identifiable {
    public let id: UUID
    public let date: Date
    public let night: DayPartConfiguration
    public let day: DayPartConfiguration

    public init(
        id: UUID = UUID(),
        date: Date,
        night: DayPartConfiguration,
        day: DayPartConfiguration
    ) {
        self.id = id
        self.date = date
        self.night = night
        self.day = day
    }
}

// MARK: - Day Part Configuration

public struct DayPartConfiguration: Sendable, Identifiable {
    public let id: UUID
    public let phenomenon: String
    public let temperatureRange: TemperatureRange
    public let description: String
    public let places: [PlaceConfiguration]
    public let winds: [WindConfiguration]
    public let seaCondition: String?
    public let lakeCondition: String?

    public init(
        id: UUID = UUID(),
        phenomenon: String,
        temperatureRange: TemperatureRange,
        description: String,
        places: [PlaceConfiguration] = [],
        winds: [WindConfiguration] = [],
        seaCondition: String? = nil,
        lakeCondition: String? = nil
    ) {
        self.id = id
        self.phenomenon = phenomenon
        self.temperatureRange = temperatureRange
        self.description = description
        self.places = places
        self.winds = winds
        self.seaCondition = seaCondition
        self.lakeCondition = lakeCondition
    }
}

// MARK: - Temperature Range

public struct TemperatureRange: Sendable, Equatable {
    public let minimum: Int
    public let maximum: Int

    public init(minimum: Int, maximum: Int) {
        self.minimum = minimum
        self.maximum = maximum
    }

    /// Formatted temperature range string (e.g., "15° - 22°")
    public var formattedRange: String {
        "\(minimum)° - \(maximum)°"
    }

    /// Average temperature
    public var average: Int {
        (minimum + maximum) / 2
    }

    /// Temperature range span
    public var span: Int {
        maximum - minimum
    }
}

// MARK: - Place Configuration

public struct PlaceConfiguration: Sendable, Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let phenomenon: String
    public let temperature: PlaceTemperature?

    public init(
        id: UUID = UUID(),
        name: String,
        phenomenon: String,
        temperature: PlaceTemperature? = nil
    ) {
        self.id = id
        self.name = name
        self.phenomenon = phenomenon
        self.temperature = temperature
    }
}

// MARK: - Place Temperature

public enum PlaceTemperature: Sendable, Equatable {
    case minimum(Int)
    case maximum(Int)
    case range(TemperatureRange)

    public init?(minimum: Int?, maximum: Int?) {
        switch (minimum, maximum) {
        case let (min?, max?):
            self = .range(TemperatureRange(minimum: min, maximum: max))
        case let (min?, nil):
            self = .minimum(min)
        case let (nil, max?):
            self = .maximum(max)
        case (nil, nil):
            return nil
        }
    }

    /// Lower temperature bound, when available
    public var minimum: Int? {
        switch self {
        case let .minimum(value): value
        case .maximum: nil
        case let .range(range): range.minimum
        }
    }

    /// Upper temperature bound, when available
    public var maximum: Int? {
        switch self {
        case .minimum: nil
        case let .maximum(value): value
        case let .range(range): range.maximum
        }
    }

    /// Full temperature range when both bounds are available
    public var range: TemperatureRange? {
        switch self {
        case let .range(range): range
        case .minimum, .maximum: nil
        }
    }

    /// Formatted temperature string (e.g., "-2°", "7°", or "15° - 22°")
    public var formattedTemperature: String {
        switch self {
        case let .minimum(value), let .maximum(value):
            "\(value)°"
        case let .range(range):
            range.formattedRange
        }
    }
}

// MARK: - Wind Configuration

public struct WindConfiguration: Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let direction: String
    public let speedRange: SpeedRange
    public let gustDescription: String?

    public init(
        id: UUID = UUID(),
        name: String,
        direction: String,
        speedRange: SpeedRange,
        gustDescription: String? = nil
    ) {
        self.id = id
        self.name = name
        self.direction = direction
        self.speedRange = speedRange
        self.gustDescription = gustDescription
    }
}

// MARK: - Speed Range

public struct SpeedRange: Sendable, Equatable {
    public let minimum: Int
    public let maximum: Int

    public init(minimum: Int, maximum: Int) {
        self.minimum = minimum
        self.maximum = maximum
    }

    /// Formatted speed range string (e.g., "10-15 m/s")
    public var formattedRange: String {
        "\(minimum)-\(maximum) m/s"
    }

    /// Average speed
    public var average: Int {
        (minimum + maximum) / 2
    }
}
