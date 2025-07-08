//
//  OpenWeatherMapEndpoint.swift
//  Networking
//
//  Created by Andrius Shiaulis on 06.07.2025.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation
@testable import Networking

// https://api.openweathermap.org/data/2.5/weather?q=Tallinn&appid=YOUR_API_KEY
struct OpenWeatherMapEndpoint: Endpoint {
    var scheme: EndpointScheme = .https
    var httpMethod: HTTPMethod = .get
    var host: String = "api.openweathermap.org"
    var path: String? = "/data/2.5/weather"
    var urlQueryItems: [URLQueryItem]
    var contentType: String? = "application/json"
}
