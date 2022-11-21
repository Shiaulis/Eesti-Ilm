// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
    public enum AppStoreDescription {
        /// Have an access to the weather information in Estonia. Eesti Ilm is a simple app that gives an instant information about forecasts, provided by Estonian Weather Service. Use a widget to check the weather information instantly from your home screen.
        public static let appstoreDescription = L10n.tr("AppStoreDescription", "appstore_description")
        /// weather, forecast, Estonia, widget, Eesti, Ilm
        public static let keywords = L10n.tr("AppStoreDescription", "keywords")
    }

    public enum Strings {
        /// Hey 👋! My name is Andrius. I'm an iOS Developer from Estonia 🇪🇪. Besides being full-time developer and father of three I'm writing small apps like this. If you have any questions/concerns regarding the app, do not hesitate to contact me.
        public static let aboutMeDescription = L10n.tr("Strings", "About me description")
        /// About me
        public static let aboutMeTitle = L10n.tr("Strings", "About me title")
        /// Check Estonian weather forecast.
        public static let checkEstonianWeatherForecast = L10n.tr("Strings", "Check Estonian weather forecast.")
        /// Contact me
        public static let contactMe = L10n.tr("Strings", "Contact me")
        /// Current language
        public static let currentLanguage = L10n.tr("Strings", "Current language")
        /// Day
        public static let day = L10n.tr("Strings", "Day")
        /// Estonian Weather Forecast
        public static let estonianWeatherForecast = L10n.tr("Strings", "Estonian Weather Forecast")
        /// Forecast
        public static let forecast = L10n.tr("Strings", "Forecast")
        /// Forecast Widget
        public static let forecastWidget = L10n.tr("Strings", "Forecast Widget")
        /// Four Day Forecast
        public static let fourDayForecast = L10n.tr("Strings", "Four day forecast")
        /// Loading
        public static let loading = L10n.tr("Strings", "Loading")
        /// Night
        public static let night = L10n.tr("Strings", "Night")
        /// No data available
        public static let noDataAvailable = L10n.tr("Strings", "No data available")
        /// Observations
        public static let observations = L10n.tr("Strings", "Observations")
        /// Ready
        public static let ready = L10n.tr("Strings", "Ready")
        /// Settings
        public static let settings = L10n.tr("Strings", "Settings")
        /// The weather information is provided by
        /// Estonian Weather Service
        public static let sourceDisclaimer = L10n.tr("Strings", "Source disclaimer")
        /// Synced
        public static let synced = L10n.tr("Strings", "Synced")
        /// Syncing
        public static let syncing = L10n.tr("Strings", "Syncing")
        /// Unit testing mode
        public static let unitTestingMode = L10n.tr("Strings", "Unit testing mode")
        public enum FailedToSync {
            /// Failed to sync. Error:
            public static let error = L10n.tr("Strings", "Failed to sync. Error:")
        }
    }
}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
    private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }()
}

// swiftlint:enable convenience_type
