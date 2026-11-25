//
//  LanguageRow.swift
//  EstonianWeather
//

import SwiftUI

struct LanguageRow: View {
    let currentLanguage: String
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            LabeledContent {
                Text(self.currentLanguage)
                    .foregroundStyle(.secondary)
            } label: {
                Text("Current language")
                    .foregroundStyle(.primary)
            }
        }
        .accessibilityHint(Text("Opens app settings to change the language"))
    }
}

#Preview {
    Form {
        LanguageRow(currentLanguage: "English", action: {})
    }
}
