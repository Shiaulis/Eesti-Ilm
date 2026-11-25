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

final class EndpointTests {

    private let sut: URLSessionNetworkClient
    private let connectionProvider = MockNetworkConnectionProvider()
    private var defaultEndpoint = OpenWeatherMapEndpoint(urlQueryItems: [])

    init() {
        self.sut = URLSessionNetworkClient(connectionProvider: connectionProvider)
    }

    // MARK: - Tests -

    @Test func whenDefaultEnpoint_requestContainsCorrectURL() async throws {
        _ = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        let receivedRequest = try #require(self.connectionProvider.receivedRequest)
        #expect(receivedRequest.url?.absoluteString == "https://api.openweathermap.org/data/2.5/weather")
    }

    @Test func whenCorrectScheme_requestContainsCorrectScheme() async throws {
        let targetScheme = EndpointScheme.ftp
        self.defaultEndpoint.scheme = targetScheme
        _ = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        let receivedRequest = try #require(self.connectionProvider.receivedRequest)
        #expect(receivedRequest.scheme == targetScheme.rawValue)
    }

    @Test func whenCorrectMethod_requestContainsCorrectMethod() async throws {
        let targetMethod = HTTPMethod.post
        self.defaultEndpoint.httpMethod = targetMethod
        _ = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        let receivedRequest = try #require(self.connectionProvider.receivedRequest)
        #expect(receivedRequest.method.rawValue == targetMethod.rawValue)
    }

    @Test func whenCorrectHost_requestContainsCorrectHost() async throws {
        let targetHost = "api.wikipedia.org"
        self.defaultEndpoint.host = targetHost
        _ = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        let receivedRequest = try #require(self.connectionProvider.receivedRequest)
        #expect(receivedRequest.url?.host == targetHost)
    }

    @Test func whenCorrectPath_requestContainsCorrectPath() async throws {
        let targetPath = "/ftp/private"
        self.defaultEndpoint.path = targetPath
        _ = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        let receivedRequest = try #require(self.connectionProvider.receivedRequest)
        #expect(receivedRequest.url?.path == targetPath)
    }

    @Test func whenCorrectQueryParameters_requestContainsCorrectQueryParameters() async throws {
        let targetURLQueryItems: [URLQueryItem] = [
            .init(name: "lang", value: "eng"),
            .init(name: "q", value: "Tallinn"),
        ]
        self.defaultEndpoint.urlQueryItems = targetURLQueryItems
        _ = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        let receivedRequest = try #require(self.connectionProvider.receivedRequest)
        let urlComponents = try #require(URLComponents(string: receivedRequest.url?.absoluteString ?? ""))
        #expect(urlComponents.queryItems == targetURLQueryItems)
    }

    @Test func whenCorrectContentType_requestContainsCorrectContentType() async throws {
        let targetContentType = "application/xml"
        self.defaultEndpoint.contentType = targetContentType
        _ = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        let receivedRequest = try #require(self.connectionProvider.receivedRequest)
        #expect(receivedRequest.headerFields[.contentType] == targetContentType)
    }

    @Test func whenCorrectEndpoint_responseContainsCorrectEndpoint() async throws {
        let receivedResponse: Response = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        let receivedEndpoint = try #require(receivedResponse.endpoint as? OpenWeatherMapEndpoint)
        #expect(self.defaultEndpoint == receivedEndpoint)
    }
}
