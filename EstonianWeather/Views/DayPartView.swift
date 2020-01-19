//
//  DayPartView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 18.01.2020.
//  Copyright © 2020 Andrius Shiaulis. All rights reserved.
//

import SwiftUI

struct DayPartView: View {

    let item: ForecastDisplayItem.DayPartForecastDisplayItem

    var body: some View {
        VStack {
            HStack {
                Text(item.type)
                Spacer()
            }

            HStack {
                Spacer()
                Image(item.weatherIconName)
                    .resizable()
                    .frame(width: 64, height: 64)
                Spacer()
                Text(item.temperatureRange)
                    .font(.largeTitle)
                Spacer()
            }

            Text(item.description)
                .fixedSize(horizontal: false, vertical: true)
                .font(.caption)

            ForEach(item.places, id: \.id) { place in
                PlaceView(place: place)
            }
        }
    }
}

struct DayPartView_Previews: PreviewProvider {
    static var previews: some View {
        DayPartView(item: ForecastDisplayItem.DayPartForecastDisplayItem.test)
            .previewLayout(.fixed(width: 414, height: 300))
    }
}