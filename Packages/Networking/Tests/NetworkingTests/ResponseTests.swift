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



final class ResponseTests {

    private let sut: URLSessionNetworkClient
    private let connectionProvider = MockNetworkConnectionProvider()
    private var defaultEndpoint = OpenWeatherMapEndpoint(urlQueryItems: [])

    init() {
        self.sut = URLSessionNetworkClient(connectionProvider: connectionProvider)
    }

    // MARK: - Tests -

    @Test func whenCorrectEndpoint_responseContainsCorrectEndpoint() async throws {
        let receivedResponse: Response = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        let receivedEndpoint = try #require(receivedResponse.endpoint as? OpenWeatherMapEndpoint)
        #expect(self.defaultEndpoint == receivedEndpoint)
    }

    @Test func whenConnectionProviderReturnsData_responseContainsCorrectData() async throws {
        let expectedData: Data = Data()
        self.connectionProvider.data = expectedData

        let receivedResponse: Response = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        #expect(expectedData == receivedResponse.data)
    }

    @Test func whenConnectionProviderReturnsError_responseContainsCorrectError() async throws {
        enum TestError: Error { case test }
        let expectedError: Error = TestError.test
        self.connectionProvider.error = expectedError

        await #expect(throws: TestError.self) {
            try await self.sut.fetchResponse(for: self.defaultEndpoint)
        }
    }

}
