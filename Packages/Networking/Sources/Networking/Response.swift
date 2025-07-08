//
//  Response.swift
//  Networking
//
//  Created by Andrius Shiaulis on 04.07.2025.
//

import Foundation
import HTTPTypes

public nonisolated struct Response: Sendable {

    // MARK: - Types -

    public struct Status: Sendable {

        public enum Kind {
            /// The status code is outside the range of 100...599.
            case invalid
            /// The status code is informational (1xx) and the response is not final.
            case informational
            /// The status code is successful (2xx).
            case successful
            /// The status code is a redirection (3xx).
            case redirection
            /// The status code is a client error (4xx).
            case clientError
            /// The status code is a server error (5xx).
            case serverError
        }

        public let code: Int
        public let reason: String

        var kind: Kind {
            switch code {
            case 100..<200: return .informational
            case 200..<300: return .successful
            case 300..<400: return .redirection
            case 400..<500: return .clientError
            default: return .invalid
            }
        }

        init(from responseStatus: HTTPResponse.Status) {
            self.code = responseStatus.code
            self.reason = responseStatus.reasonPhrase
        }
    }

    // MARK: - Properties -

    public let endpoint: any Endpoint
    public let data: Data
    public let status: Status

    // MARK: - Init -

    init(endpoint: any Endpoint, data: Data, response: HTTPResponse) {
        self.endpoint = endpoint
        self.data = data
        self.status = .init(from: response.status)
    }
}
