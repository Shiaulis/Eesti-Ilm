//
//  Endpoint.swift
//
//
//  Created by Andrius Shiaulis on 06.03.2021.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation
import WeatherLocale

public nonisolated
struct Endpoint: Sendable {

    // MARK: - Types -

    public enum Scheme: String {
        case https
    }

    public nonisolated
    enum Method: String {
        case get = "GET"

        fileprivate func makeHTTPRequestMethod() -> HTTPRequest.Method {
            switch self {
            case .get: .get
            }
        }
    }

    public enum Error: Swift.Error {
        case unableToMakeURL
        case unableToMakeURLComponents
    }

    public struct Host: Sendable, RawRepresentable {
        public typealias RawValue = String
        public let rawValue: RawValue

        public init?(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }

    // MARK: - Properties -

    let request: HTTPRequest

    // MARK: - Init -

    init(scheme: Scheme, host: Host, path: String? = nil, urlQueryItems: [URLQueryItem] = [], method: Method = .get, contentType: String? = nil) {

        var request = HTTPRequest(
            method: method.makeHTTPRequestMethod(),
            scheme: scheme.rawValue,
            authority: host.rawValue,
            path: path
        )

        request.headerFields[.contentType] = contentType
        if !urlQueryItems.isEmpty {
            request.url?.append(queryItems: urlQueryItems)
        }
        self.request = request
    }
}
