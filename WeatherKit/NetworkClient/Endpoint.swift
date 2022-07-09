//
//  File.swift
//
//
//  Created by Andrius Shiaulis on 06.03.2021.
//

import Foundation

public struct Endpoint {
    static let scheme = "https"
    static let host = "ilmateenistus.ee"

    let path: String
    let urlQueryItems: [URLQueryItem]?
    let method: Method

    private init(path: String, urlQueryItems: [URLQueryItem]? = nil, method: Method = .post) {
        self.path = path
        self.urlQueryItems = urlQueryItems
        self.method = method
    }

}

extension Endpoint {

    enum Method: String {
        case post = "POST"
        var string: String { self.rawValue }
    }

    enum Error: Swift.Error {
        case badURL
    }

}

extension Endpoint {

    // https://ilmateenistus.ee/ilma_andmed/xml/forecast.php?lang=rus

    static func forecast(for locale: WeatherLocale) -> Endpoint {
        .init(
            path: "/ilma_andmed/xml/forecast.php",
            urlQueryItems: [.init(name: "lang", value: locale.queryItemLanguageCode())],
            method: .post
        )
    }

    // https://lmateenistus.ee/ilma_andmed/xml/observations.php

    static func observations() -> Endpoint {
        .init(path: "/ilma_andmed/xml/observations.php")
    }
}

private extension WeatherLocale {
    func queryItemLanguageCode() -> String {
        switch self {
        case .english: return "eng"
        case .estonian: return "est"
        case .russian: return "rus"
        }
    }
}

extension Endpoint {

    func generateURL() throws -> URL {
        var components = URLComponents()
        components.scheme = Endpoint.scheme
        components.host = Endpoint.host
        components.path = self.path
        components.queryItems = self.urlQueryItems

        guard let url = components.url else { throw Error.badURL }

        return url
    }

    func generateRequest() throws -> URLRequest {
        var request = URLRequest(url: try generateURL())
        request.httpMethod = self.method.string
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        return request
    }

}
