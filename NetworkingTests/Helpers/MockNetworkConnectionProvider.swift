//
//  MockNetworkConnectionProvider.swift
//  Networking
//
//  Created by Andrius Shiaulis on 06.07.2025.
//

import Foundation
import HTTPTypes
@testable import Networking

final class MockNetworkConnectionProvider: NetworkConnectionProvider {
    var receivedRequest: HTTPRequest?
    var data: Data!
    var error: Error?
    var status: Response.Status?

    func data(for request: HTTPRequest) async throws -> (Data, HTTPResponse) {
        self.receivedRequest = request

        if let error {
            throw error
        }

        let httpStatus: HTTPResponse.Status = if let status {
            .init(code: status.code, reasonPhrase: status.reason)
        }
        else {
            .ok
        }

        return (self.data ?? .init(), HTTPResponse(status: httpStatus))
    }
}
