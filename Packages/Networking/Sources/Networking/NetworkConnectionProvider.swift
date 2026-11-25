//
//  NetworkConnectionProvider.swift
//  Networking
//
//  Created by Andrius Shiaulis on 04.07.2025.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

protocol NetworkConnectionProvider {
    func data(for request: HTTPRequest) async throws -> (Data, HTTPResponse)
}

extension URLSession: NetworkConnectionProvider {}
