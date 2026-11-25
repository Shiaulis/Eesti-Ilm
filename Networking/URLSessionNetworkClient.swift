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

    public func fetchResponse(for endpoint: any Endpoint) async throws -> Response {
        let request = try await self.makeHTTPRequest(for: endpoint)
        let (body, httpResponse) = try await self.connectionProvider.data(for: request)
        let response = Response(endpoint: endpoint, data: body, response: httpResponse)
        guard response.status.kind == .successful else {
            throw NetworkError.unsuccessfulResponse(response)
        }

        return response
    }

    // MARK: - Private API -

    func makeHTTPRequest(for endpoint: any Endpoint) async throws -> HTTPRequest {
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
        case .get: .get
        case .post: .post
        case .put: .put
        case .delete: .delete
        }
    }
}
