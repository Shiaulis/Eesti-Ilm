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

public final nonisolated class URLSessionNetworkClient {

    // MARK: - Properties -

    private let connectionProvider: NetworkConnectionProvider

    // MARK: - Init -

    public convenience init(urlSession: URLSession) {
        self.init(connectionProvider: urlSession)
    }

    init(connectionProvider: NetworkConnectionProvider) {
        self.connectionProvider = connectionProvider
    }

    // MARK: - Public API -

    public func fetchResponse(for endpoint: Endpoint) async throws -> Response {
        let request = try await self.makeHTTPRequest(for: endpoint)
        let (body, response) = try await self.connectionProvider.data(for: request)
        return .init(data: body, response: response)
    }

    // MARK: - Private API -

    func makeHTTPRequest(for endpoint: Endpoint) async throws -> HTTPRequest {
        var request = HTTPRequest(
            method: makeRequestMethod(from: endpoint.httpMethod),
            scheme: endpoint.scheme.rawValue,
            authority: endpoint.host,
            path: endpoint.path
        )

        request.headerFields[.contentType] = endpoint.contentType
        if !endpoint.urlQueryItems.isEmpty {
            request.url?.append(queryItems: endpoint.urlQueryItems)
        }

        return request
    }

    private func makeRequestMethod(from endpointMethod: HTTPMethod) -> HTTPRequest.Method {
        switch endpointMethod {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        }
    }
}
