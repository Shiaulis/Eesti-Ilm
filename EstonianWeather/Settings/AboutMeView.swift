//
//  AboutMeView.swift
//  EstonianWeather
//

import SwiftUI

struct AboutMeView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(.shiaulis)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(radius: 10)
                    .frame(maxWidth: 400)
                    .accessibilityHidden(true)

                Text(.aboutMeDescription)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let contactURL = SettingsConfiguration.contactURL() {
                    Button("Contact me") {
                        self.openURL(contactURL)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .navigationTitle("About me")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutMeView()
    }
}
