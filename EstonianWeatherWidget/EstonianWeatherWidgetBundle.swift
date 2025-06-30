//
//  EstonianWeatherWidgetBundle.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 11.10.2020.
//

import SwiftUI
import WidgetKit

/// All widgets should be mentioned in this method
@main
struct EstonianWeatherWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ForecastWidget()
    }
}
