//
//  RootView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 12.01.2020.
//  Copyright © 2020 Andrius Shiaulis. All rights reserved.
//

import SwiftUI

struct RootView: View {

    @ObservedObject var viewModel: RootViewMolel = RootViewMolel()

    var body: some View {
        List(self.viewModel.displayItems) { item in
            ForecastView(item: item)
                .padding(.horizontal)
        }
        .onAppear {
            self.viewModel.fetch()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}