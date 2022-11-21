//
//  AboutMeView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 22.11.2020.
//

import SwiftUI
import Strings

struct AboutMeView: View {
    var body: some View {
        ScrollView {
            VStack {
                HStack(spacing: 64) {
                    Spacer()
                    Image("shiaulis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: 10)
                        .frame(maxWidth: 400)
                        .padding()
                    Spacer()
                }
                Text(L10n.Strings.aboutMeDescription)
                    .padding()
                ContactMeButton()
                Spacer()
            }
        }
        .navigationBarTitle(L10n.Strings.aboutMeTitle)
    }
}

private struct ContactMeButton: View {

    var body: some View {
        Button(action: buttonAction) {
            Text(L10n.Strings.contactMe)
        }
    }

    private func buttonAction() {
        UIApplication.shared.open(URL.email)
    }
}

struct AboutMeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutMeView()
                .navigationTitle(L10n.Strings.aboutMeTitle)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
