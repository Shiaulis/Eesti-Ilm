//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map { Locale(identifier: $0) }
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  /// This `R.color` struct is generated, and contains static references to 1 colors.
  struct color {
    /// Color `AccentColor`.
    static let accentColor = Rswift.ColorResource(bundle: R.hostingBundle, name: "AccentColor")

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "AccentColor", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func accentColor(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.accentColor, compatibleWith: traitCollection)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "AccentColor", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func accentColor(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.accentColor.name)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.entitlements` struct is generated, and contains static references to 1 properties.
  struct entitlements {
    struct comAppleSecurityApplicationGroups {
      static let groupShiaulisEstonianWeather = infoPlistString(path: ["com.apple.security.application-groups"], key: "group.shiaulis.EstonianWeather") ?? "group.shiaulis.EstonianWeather"

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  /// This `R.file` struct is generated, and contains static references to 2 files.
  struct file {
    /// Resource file `LICENSE`.
    static let licensE = Rswift.FileResource(bundle: R.hostingBundle, name: "LICENSE", pathExtension: "")
    /// Resource file `Settings.bundle`.
    static let settingsBundle = Rswift.FileResource(bundle: R.hostingBundle, name: "Settings", pathExtension: "bundle")

    /// `bundle.url(forResource: "LICENSE", withExtension: "")`
    static func licensE(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.licensE
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "Settings", withExtension: "bundle")`
    static func settingsBundle(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.settingsBundle
      return fileResource.bundle.url(forResource: fileResource)
    }

    fileprivate init() {}
  }

  /// This `R.image` struct is generated, and contains static references to 1 images.
  struct image {
    /// Image `shiaulis`.
    static let shiaulis = Rswift.ImageResource(bundle: R.hostingBundle, name: "shiaulis")

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "shiaulis", bundle: ..., traitCollection: ...)`
    static func shiaulis(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.shiaulis, compatibleWith: traitCollection)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.info` struct is generated, and contains static references to 2 properties.
  struct info {
    struct nsUserActivityTypes {
      static let configurationIntent = infoPlistString(path: ["NSUserActivityTypes"], key: "ConfigurationIntent") ?? "ConfigurationIntent"

      fileprivate init() {}
    }

    struct uiApplicationSceneManifest {
      static let _key = "UIApplicationSceneManifest"
      static let uiApplicationSupportsMultipleScenes = true

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  /// This `R.string` struct is generated, and contains static references to 1 localization tables.
  struct string {
    /// This `R.string.localizable` struct is generated, and contains static references to 21 localization keys.
    struct localizable {
      /// en translation: About me
      ///
      /// Locales: en, et, ru
      static let aboutMeTitle = Rswift.StringResource(key: "About me title", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Check Estonian weather forecast.
      ///
      /// Locales: en, et, ru
      static let checkEstonianWeatherForecast = Rswift.StringResource(key: "Check Estonian weather forecast.", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Contact me
      ///
      /// Locales: en, et, ru
      static let contactMe = Rswift.StringResource(key: "Contact me", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Current language
      ///
      /// Locales: en, et, ru
      static let currentLanguage = Rswift.StringResource(key: "Current language", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Day
      ///
      /// Locales: en, et, ru
      static let day = Rswift.StringResource(key: "Day", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Estonian Weather Forecast
      ///
      /// Locales: en, et, ru
      static let estonianWeatherForecast = Rswift.StringResource(key: "Estonian Weather Forecast", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Failed to sync. Error:
      ///
      /// Locales: en, et, ru
      static let failedToSyncError = Rswift.StringResource(key: "Failed to sync. Error:", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Forecast
      ///
      /// Locales: en, et, ru
      static let forecast = Rswift.StringResource(key: "Forecast", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Forecast Widget
      ///
      /// Locales: en, et, ru
      static let forecastWidget = Rswift.StringResource(key: "Forecast Widget", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Four Day Forecast
      ///
      /// Locales: en, et, ru
      static let fourDayForecast = Rswift.StringResource(key: "Four day forecast", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Hey 👋! My name is Andrius. I'm an iOS Developer from Estonia 🇪🇪. Besides being full-time developer and father of three I'm writing small apps like this. If you have any questions/concerns regarding the app, do not hesitate to contact me.
      ///
      /// Locales: en, et, ru
      static let aboutMeDescription = Rswift.StringResource(key: "About me description", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Loading
      ///
      /// Locales: en, et, ru
      static let loading = Rswift.StringResource(key: "Loading", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Night
      ///
      /// Locales: en, et, ru
      static let night = Rswift.StringResource(key: "Night", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: No data available
      ///
      /// Locales: en, et, ru
      static let noDataAvailable = Rswift.StringResource(key: "No data available", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Observations
      ///
      /// Locales: en, et, ru
      static let observations = Rswift.StringResource(key: "Observations", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Ready
      ///
      /// Locales: en, et, ru
      static let ready = Rswift.StringResource(key: "Ready", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Settings
      ///
      /// Locales: en, et, ru
      static let settings = Rswift.StringResource(key: "Settings", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Synced
      ///
      /// Locales: en, et, ru
      static let synced = Rswift.StringResource(key: "Synced", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Syncing
      ///
      /// Locales: en, et, ru
      static let syncing = Rswift.StringResource(key: "Syncing", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: The weather information is provided by Estonian Weather Service
      ///
      /// Locales: en, et, ru
      static let sourceDisclaimer = Rswift.StringResource(key: "Source disclaimer", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)
      /// en translation: Unit testing mode
      ///
      /// Locales: en, et, ru
      static let unitTestingMode = Rswift.StringResource(key: "Unit testing mode", tableName: "Localizable", bundle: R.hostingBundle, locales: ["en", "et", "ru"], comment: nil)

      /// en translation: About me
      ///
      /// Locales: en, et, ru
      static func aboutMeTitle(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("About me title", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "About me title"
        }

        return NSLocalizedString("About me title", bundle: bundle, comment: "")
      }

      /// en translation: Check Estonian weather forecast.
      ///
      /// Locales: en, et, ru
      static func checkEstonianWeatherForecast(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Check Estonian weather forecast.", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Check Estonian weather forecast."
        }

        return NSLocalizedString("Check Estonian weather forecast.", bundle: bundle, comment: "")
      }

      /// en translation: Contact me
      ///
      /// Locales: en, et, ru
      static func contactMe(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Contact me", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Contact me"
        }

        return NSLocalizedString("Contact me", bundle: bundle, comment: "")
      }

      /// en translation: Current language
      ///
      /// Locales: en, et, ru
      static func currentLanguage(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Current language", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Current language"
        }

        return NSLocalizedString("Current language", bundle: bundle, comment: "")
      }

      /// en translation: Day
      ///
      /// Locales: en, et, ru
      static func day(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Day", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Day"
        }

        return NSLocalizedString("Day", bundle: bundle, comment: "")
      }

      /// en translation: Estonian Weather Forecast
      ///
      /// Locales: en, et, ru
      static func estonianWeatherForecast(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Estonian Weather Forecast", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Estonian Weather Forecast"
        }

        return NSLocalizedString("Estonian Weather Forecast", bundle: bundle, comment: "")
      }

      /// en translation: Failed to sync. Error:
      ///
      /// Locales: en, et, ru
      static func failedToSyncError(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Failed to sync. Error:", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Failed to sync. Error:"
        }

        return NSLocalizedString("Failed to sync. Error:", bundle: bundle, comment: "")
      }

      /// en translation: Forecast
      ///
      /// Locales: en, et, ru
      static func forecast(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Forecast", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Forecast"
        }

        return NSLocalizedString("Forecast", bundle: bundle, comment: "")
      }

      /// en translation: Forecast Widget
      ///
      /// Locales: en, et, ru
      static func forecastWidget(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Forecast Widget", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Forecast Widget"
        }

        return NSLocalizedString("Forecast Widget", bundle: bundle, comment: "")
      }

      /// en translation: Four Day Forecast
      ///
      /// Locales: en, et, ru
      static func fourDayForecast(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Four day forecast", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Four day forecast"
        }

        return NSLocalizedString("Four day forecast", bundle: bundle, comment: "")
      }

      /// en translation: Hey 👋! My name is Andrius. I'm an iOS Developer from Estonia 🇪🇪. Besides being full-time developer and father of three I'm writing small apps like this. If you have any questions/concerns regarding the app, do not hesitate to contact me.
      ///
      /// Locales: en, et, ru
      static func aboutMeDescription(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("About me description", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "About me description"
        }

        return NSLocalizedString("About me description", bundle: bundle, comment: "")
      }

      /// en translation: Loading
      ///
      /// Locales: en, et, ru
      static func loading(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Loading", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Loading"
        }

        return NSLocalizedString("Loading", bundle: bundle, comment: "")
      }

      /// en translation: Night
      ///
      /// Locales: en, et, ru
      static func night(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Night", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Night"
        }

        return NSLocalizedString("Night", bundle: bundle, comment: "")
      }

      /// en translation: No data available
      ///
      /// Locales: en, et, ru
      static func noDataAvailable(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("No data available", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "No data available"
        }

        return NSLocalizedString("No data available", bundle: bundle, comment: "")
      }

      /// en translation: Observations
      ///
      /// Locales: en, et, ru
      static func observations(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Observations", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Observations"
        }

        return NSLocalizedString("Observations", bundle: bundle, comment: "")
      }

      /// en translation: Ready
      ///
      /// Locales: en, et, ru
      static func ready(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Ready", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Ready"
        }

        return NSLocalizedString("Ready", bundle: bundle, comment: "")
      }

      /// en translation: Settings
      ///
      /// Locales: en, et, ru
      static func settings(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Settings", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Settings"
        }

        return NSLocalizedString("Settings", bundle: bundle, comment: "")
      }

      /// en translation: Synced
      ///
      /// Locales: en, et, ru
      static func synced(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Synced", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Synced"
        }

        return NSLocalizedString("Synced", bundle: bundle, comment: "")
      }

      /// en translation: Syncing
      ///
      /// Locales: en, et, ru
      static func syncing(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Syncing", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Syncing"
        }

        return NSLocalizedString("Syncing", bundle: bundle, comment: "")
      }

      /// en translation: The weather information is provided by Estonian Weather Service
      ///
      /// Locales: en, et, ru
      static func sourceDisclaimer(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Source disclaimer", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Source disclaimer"
        }

        return NSLocalizedString("Source disclaimer", bundle: bundle, comment: "")
      }

      /// en translation: Unit testing mode
      ///
      /// Locales: en, et, ru
      static func unitTestingMode(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("Unit testing mode", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
          return "Unit testing mode"
        }

        return NSLocalizedString("Unit testing mode", bundle: bundle, comment: "")
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      // There are no resources to validate
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R {
  fileprivate init() {}
}
