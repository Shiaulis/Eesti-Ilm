//
//  MockNetworkConnectionProvider.swift
//  Networking
//
//  Created by Andrius Shiaulis on 06.07.2025.
//

import Foundation
@testable import Networking
import HTTPTypes

final class MockNetworkConnectionProvider: NetworkConnectionProvider {
    var receivedRequest: HTTPRequest?
    var data: Data!
    var error: Error?
    var status: Response.Status?

    func data(for request: HTTPRequest) async throws -> (Data, HTTPResponse) {
        self.receivedRequest = request

        if let error { throw error }
        return (self.data ?? .init(), HTTPResponse(status: .init(code: status?.code ?? 0, reasonPhrase: status?.reason ?? "")))
    }
}
