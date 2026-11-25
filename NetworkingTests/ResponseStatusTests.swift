//
//  ResponseStatusTests.swift
//  Networking
//
//  Created by Andrius Shiaulis on 25.11.2026.
//

import HTTPTypes
@testable import Networking
import Testing

struct ResponseStatusTests {

    // MARK: - Status Kind Classification -

    @Test(arguments: [100, 101, 199])
    func informationalStatusCodes_classifyAsInformational(code: Int) {
        let status = Response.Status(code: code)
        #expect(status.kind == .informational)
    }

    @Test(arguments: [200, 201, 204, 299])
    func successfulStatusCodes_classifyAsSuccessful(code: Int) {
        let status = Response.Status(code: code)
        #expect(status.kind == .successful)
    }

    @Test(arguments: [300, 301, 304, 399])
    func redirectionStatusCodes_classifyAsRedirection(code: Int) {
        let status = Response.Status(code: code)
        #expect(status.kind == .redirection)
    }

    @Test(arguments: [400, 404, 429, 499])
    func clientErrorStatusCodes_classifyAsClientError(code: Int) {
        let status = Response.Status(code: code)
        #expect(status.kind == .clientError)
    }

    @Test(arguments: [500, 502, 503, 599])
    func serverErrorStatusCodes_classifyAsServerError(code: Int) {
        let status = Response.Status(code: code)
        #expect(status.kind == .serverError)
    }

    @Test(arguments: [-100, -1, 0, 99, 600, 999, 1000])
    func outOfRangeStatusCodes_classifyAsInvalid(code: Int) {
        let status = Response.Status(code: code)
        #expect(status.kind == .invalid)
    }

    // MARK: - HTTPResponse.Status Mapping -

    @Test func initFromHTTPResponseStatus_mapsCodeReasonAndKind() {
        let status = Response.Status(from: .serviceUnavailable)
        #expect(status.code == 503)
        #expect(status.reason == "Service Unavailable")
        #expect(status.kind == .serverError)
    }
}
