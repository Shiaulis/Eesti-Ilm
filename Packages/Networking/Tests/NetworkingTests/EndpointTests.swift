//
//  EndpointTests.swift
//  Networking
//
//  Created by Andrius Shiaulis on 04.07.2025.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation
@testable import Networking
import Testing

struct EndpointTests {

    // MARK: - Tests -

    @Test func whenCorrectScheme_requestContainsCorrectScheme() async throws {
        let scheme = Endpoint.Scheme.https
        let request = try makeRequest(scheme: scheme)
        #expect(request.scheme == scheme.rawValue)
    }

    @Test func whenCorrectHost_requestContainsCorrectHost() async throws {
        let host = Endpoint.Host(rawValue: "host")!
        let request = try makeRequest(host: host)
        #expect(request.authority == host.rawValue)
    }

    @Test func whenCorrectPath_requestContainsCorrectPath() async throws {
        let path = "/test"
        let request = try makeRequest(path: path)
        #expect(request.path == path)
    }

    @Test func whenCorrectQueryParameters_requestContainsCorrectQueryParameters() async throws {
        let urlQueryItems: [URLQueryItem] = [
            .init(name: "key", value: "value"),
        ]
        let request = try makeRequest(urlQueryItems: urlQueryItems)
        let url = try #require(request.url)
        let urlComponents = try #require(URLComponents(string: url.absoluteString))
        #expect(urlComponents.queryItems?.first == urlQueryItems.first)
    }

    @Test func whenCorrectMethod_requestContainsCorrectMethod() async throws {
        let method = Endpoint.Method.get
        let request = try makeRequest(method: method)
        #expect(request.method.rawValue == method.rawValue)
    }

    @Test func whenCorrectContentType_requestContainsCorrectContentType() async throws {
        let contentType = "application/json"
        let request = try makeRequest(contentType: contentType)
        #expect(request.headerFields.first?.value == contentType)
    }

    @Test func whenCorrectComponents_requestFullURLCorrect() async throws {
        // https://ilmateenistus.ee/ilma_andmed/xml/forecast.php?lang=eng
        let request = try makeRequest(
            scheme: .https,
            host: .init(rawValue: "ilmateenistus.ee")!,
            path: "/ilma_andmed/xml/forecast.php",
            urlQueryItems: [.init(name: "lang", value: "eng")]
        )
        #expect(request.url?.absoluteString == "https://ilmateenistus.ee/ilma_andmed/xml/forecast.php?lang=eng")
    }

    // MARK: - Private API -

    private func makeRequest(
        scheme: Endpoint.Scheme = .https,
        host: Endpoint.Host = .init(rawValue: "host")!,
        path: String = "/test",
        urlQueryItems: [URLQueryItem] = [],
        method: Endpoint.Method = .get,
        contentType: String? = nil
    ) throws -> HTTPRequest {
        Endpoint(
            scheme: scheme,
            host: host,
            path: path,
            urlQueryItems: urlQueryItems,
            method: method,
            contentType: contentType
        ).request
    }
}
