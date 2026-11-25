//
//  ResponseTests.swift
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
        let expectedData = Data()
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

    @Test(arguments: [200, 201, 204, 299])
    func whenConnectionProviderReturns2xxStatus_returnsResponse(code: Int) async throws {
        let expectedData = Data("ok".utf8)
        self.connectionProvider.data = expectedData
        self.connectionProvider.status = Response.Status(code: code, reason: "OK")

        let receivedResponse = try await self.sut.fetchResponse(for: self.defaultEndpoint)
        #expect(receivedResponse.status.code == code)
        #expect(receivedResponse.status.reason == "OK")
        #expect(receivedResponse.status.kind == .successful)
        #expect(receivedResponse.data == expectedData)
    }

    @Test(arguments: [
        (0, Response.Status.Kind.invalid),
        (99, Response.Status.Kind.invalid),
        (100, Response.Status.Kind.informational),
        (199, Response.Status.Kind.informational),
        (300, Response.Status.Kind.redirection),
        (302, Response.Status.Kind.redirection),
        (399, Response.Status.Kind.redirection),
        (400, Response.Status.Kind.clientError),
        (404, Response.Status.Kind.clientError),
        (499, Response.Status.Kind.clientError),
        (500, Response.Status.Kind.serverError),
        (502, Response.Status.Kind.serverError),
        (503, Response.Status.Kind.serverError),
        (599, Response.Status.Kind.serverError),
        (600, Response.Status.Kind.invalid),
        (999, Response.Status.Kind.invalid),
    ])
    func whenConnectionProviderReturnsNon2xxStatus_throwsUnsuccessfulResponse(
        code: Int,
        expectedKind: Response.Status.Kind
    ) async throws {
        self.connectionProvider.status = Response.Status(code: code)

        let error = await #expect(throws: NetworkError.self) {
            try await self.sut.fetchResponse(for: self.defaultEndpoint)
        }

        let receivedResponse = try extractUnsuccessfulResponse(from: error)
        #expect(receivedResponse.status.code == code)
        #expect(receivedResponse.status.kind == expectedKind)
    }

    @Test func whenConnectionProviderReturnsServerError_thrownErrorPreservesResponseDetails() async throws {
        let expectedData = Data("Service unavailable".utf8)
        self.connectionProvider.data = expectedData
        self.connectionProvider.status = Response.Status(code: 503, reason: "Service Unavailable")

        let error = await #expect(throws: NetworkError.self) {
            try await self.sut.fetchResponse(for: self.defaultEndpoint)
        }

        let receivedResponse = try extractUnsuccessfulResponse(from: error)
        let receivedEndpoint = try #require(receivedResponse.endpoint as? OpenWeatherMapEndpoint)
        #expect(receivedEndpoint == self.defaultEndpoint)
        #expect(receivedResponse.data == expectedData)
        #expect(receivedResponse.status == Response.Status(code: 503, reason: "Service Unavailable"))
        #expect(receivedResponse.status.kind == .serverError)
        #expect(error?.errorDescription == "Unsuccessful HTTP response: 503 Service Unavailable")
        #expect(error?.description == "Unsuccessful HTTP response: 503 Service Unavailable")
    }

    @Test func whenUnsuccessfulResponseHasEmptyReason_errorDescriptionIncludesStatusKind() async throws {
        self.connectionProvider.status = Response.Status(code: 500)

        let error = await #expect(throws: NetworkError.self) {
            try await self.sut.fetchResponse(for: self.defaultEndpoint)
        }

        #expect(error?.errorDescription == "Unsuccessful HTTP response: 500 (serverError)")
        #expect(error?.description == "Unsuccessful HTTP response: 500 (serverError)")
    }

    // MARK: - Helpers -

    private func extractUnsuccessfulResponse(from error: NetworkError?) throws -> Response {
        let networkError = try #require(error)
        switch networkError {
        case let .unsuccessfulResponse(response):
            return response
        }
    }
}
