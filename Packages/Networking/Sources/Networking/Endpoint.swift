//
//  Endpoint.swift
//  Networking
//
//  Created by Andrius Shiaulis on 04.07.2025.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

public enum EndpointScheme: String, Sendable {
    case https, ftp
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public nonisolated protocol Endpoint: Sendable, Hashable {

    // MARK: - Properties -

    var scheme: EndpointScheme { get }
    var httpMethod: HTTPMethod { get }
    var host: String { get }
    var path: String? { get }
    var urlQueryItems: [URLQueryItem] { get }
    var contentType: String? { get }

}
