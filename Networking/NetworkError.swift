//
//  NetworkError.swift
//  Networking
//
//  Created by Andrius Shiaulis on 25.11.2026.
//

import Foundation

public nonisolated enum NetworkError: LocalizedError, CustomStringConvertible, Sendable {
    case unsuccessfulResponse(Response)

    public var errorDescription: String? {
        switch self {
        case let .unsuccessfulResponse(response):
            if response.status.reason.isEmpty {
                "Unsuccessful HTTP response: \(response.status.code) (\(response.status.kind))"
            }
            else {
                "Unsuccessful HTTP response: \(response.status.code) \(response.status.reason)"
            }
        }
    }

    public var description: String {
        self.errorDescription ?? "NetworkError"
    }
}
