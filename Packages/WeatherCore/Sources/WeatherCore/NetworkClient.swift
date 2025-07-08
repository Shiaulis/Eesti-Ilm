//
//  NetworkClient.swift
//  WeatherCore
//
//  Created by Andrius Shiaulis on 06.07.2025.
//

import Foundation
import Networking

nonisolated protocol WeatherNetworkClient {

    func getForecastData(for language: WeatherLanguage) async throws -> Data

}

private struct ForecastEndpoint: Endpoint {
    let scheme: Networking.EndpointScheme = .https
    let httpMethod: Networking.HTTPMethod = .get
    let host: String = "ilmateenistus.ee"
    let path: String? = "/ilma_andmed/xml/forecast.php"
    let urlQueryItems: [URLQueryItem]
    let contentType: String? = "application/x-www-form-urlencoded;charset=UTF-8"

    init(language: WeatherLanguage) {
        let languageCode: String = switch language {
        case .estonian: "est"
        case .english: "eng"
        }

        self.urlQueryItems = [.init(name: "lang", value: languageCode)]
    }
}

extension URLSessionNetworkClient: WeatherNetworkClient {

    func getForecastData(for language: WeatherLanguage) async throws -> Data {
        let endpoint = ForecastEndpoint(language: language)
        let response = try await fetchResponse(for: endpoint)
        return response.data
    }
}
