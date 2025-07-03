//
//  URLSessionNetworkClient.swift
//  Networking
//
//  Created by Andrius Shiaulis on 04.07.2025.
//


import Combine
import Foundation
import HTTPTypes
import HTTPTypesFoundation

public final nonisolated
class URLSessionNetworkClient {

    // MARK: - Properties -

    private let urlSession: URLSession

    // MARK: - Init -

    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    // MARK: - Public API -

    public func fetchResponse(for endpoint: Endpoint) async throws -> Response {
        let (body, response) = try await self.urlSession.data(for: endpoint.request)
        return .init(data: body, response: response)
    }
}
