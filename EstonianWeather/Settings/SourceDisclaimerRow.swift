//
//  SourceDisclaimerRow.swift
//  EstonianWeather
//

import SwiftUI

struct SourceDisclaimerRow: View {
    let url: URL
    let urlDescription: String

    var body: some View {
        VStack(spacing: 8) {
            Text(.sourceDisclaimer)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Link(destination: self.url) {
                Text(verbatim: self.urlDescription)
            }
        }
        .font(.caption)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    Form {
        if let url = SettingsConfiguration.sourceDisclaimerURL(
            locale: Locale(identifier: "en_US"),
            preferredLocalizations: ["en"]
        ) {
            SourceDisclaimerRow(
                url: url,
                urlDescription: SettingsConfiguration.sourceDisclaimerHost
            )
        }
    }
}
