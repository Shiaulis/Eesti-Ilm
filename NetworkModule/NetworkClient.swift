//
//  File.swift
//
//
//  Created by Andrius Shiaulis on 06.03.2021.
//

import Foundation
import Combine

public protocol NetworkClient {

    func data(from endpoint: Endpoint) async throws -> (Data, URLResponse)

}

public final class URLSessionNetworkClient: NSObject {

    private let urlSession = URLSession.shared

}

extension URLSessionNetworkClient: NetworkClient {

    public func data(from endpoint: Endpoint) async throws -> (Data, URLResponse) {
        let request = try endpoint.generateRequest()
        return try await self.urlSession.data(for: request)
    }

    public enum Error: Swift.Error {
        case noDataFoundInResponse
        case dataTaskError(urlError: URLError)
        case notSupportedIOSVersion
    }

}
