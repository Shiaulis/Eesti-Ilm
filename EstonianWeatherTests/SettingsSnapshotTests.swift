//
//  SettingsSnapshotTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Testing

struct SettingsSnapshotTests {
    @Test func buildsLanguageAboutMeSupportAndDisclaimerSectionsInOrder() {
        let snapshot = SettingsSnapshot.make(includesDisclaimer: true)

        #expect(snapshot.sectionIdentifiers == [.language, .aboutMe, .support, .disclaimer])
        #expect(snapshot.itemIdentifiers(inSection: .language) == [.currentLanguage])
        #expect(snapshot.itemIdentifiers(inSection: .aboutMe) == [.aboutMe])
        #expect(snapshot.itemIdentifiers(inSection: .support) == [.support, .privacyPolicy])
        #expect(snapshot.itemIdentifiers(inSection: .disclaimer) == [.disclaimer])
    }

    @Test func omitsDisclaimerSectionWhenExcluded() {
        let snapshot = SettingsSnapshot.make(includesDisclaimer: false)

        #expect(snapshot.sectionIdentifiers == [.language, .aboutMe, .support])
        #expect(snapshot.itemIdentifiers(inSection: .language) == [.currentLanguage])
        #expect(snapshot.itemIdentifiers(inSection: .aboutMe) == [.aboutMe])
        #expect(snapshot.itemIdentifiers(inSection: .support) == [.support, .privacyPolicy])
    }
}
