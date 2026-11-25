# Networking
[![CI](https://github.com/Shiaulis/networking/actions/workflows/ci.yml/badge.svg)](https://github.com/Shiaulis/networking/actions/workflows/ci.yml)

A lightweight Swift package for making network requests with [`HTTPTypes`](https://github.com/apple/swift-http-types) and `URLSession`. You describe a request as an `Endpoint` value and execute it with `URLSessionNetworkClient` using Swift concurrency (`async`/`await`). The package is written in Swift 6 language mode with strict concurrency checking.

## Main Components
- **`Endpoint` protocol:** describes a request: `scheme` (`EndpointScheme`: `.https`, `.ftp`), `httpMethod` (`HTTPMethod`: `.get`, `.post`, `.put`, `.delete`), `host`, optional `path`, `urlQueryItems` and optional `contentType`. Conforming types must be `Sendable` and `Hashable`.
- **`URLSessionNetworkClient`:** builds an `HTTPRequest` from an `Endpoint`, runs it on the `URLSession` you pass in, and returns a `Response`.
- **`Response`:** the originating `endpoint`, the raw body `data`, and a `status` with the HTTP status `code` and `reason` phrase.

## Requirements
- iOS 27.0+ / macOS 26.0+
- Xcode 27.2+ (Swift tools version 6.4)

## Installation
Add `Networking` with Swift Package Manager.

In `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/Shiaulis/networking.git", from: "0.4.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Networking", package: "networking"),
        ]
    ),
]
```

In Xcode: **File > Add Package Dependencies...**, enter `https://github.com/Shiaulis/networking.git` and choose version `0.4.0` or later.

## Usage

### 1. Define Your Endpoint
Create a type that conforms to `Endpoint`.
```swift
import Foundation
import Networking

struct GitHubUserEndpoint: Endpoint {
    let username: String

    var scheme: EndpointScheme { .https }
    var httpMethod: HTTPMethod { .get }
    var host: String { "api.github.com" }
    var path: String? { "/users/\(username)" }
    var urlQueryItems: [URLQueryItem] { [] }
    var contentType: String? { "application/json" }
}
```

### 2. Make a Network Request
Create a `URLSessionNetworkClient` and fetch a response for your endpoint.
```swift
import Foundation
import Networking

let client = URLSessionNetworkClient(urlSession: .shared)
let endpoint = GitHubUserEndpoint(username: "octocat")

do {
    let response = try await client.fetchResponse(for: endpoint)
    print("Status \(response.status.code), \(response.data.count) bytes")
}
catch {
    print("Request failed: \(error)")
}
```

## Development
Build, test and format commands, CI and conventions are described in [AGENTS.md](AGENTS.md).

## Contributing
Contributions are welcome. Open an issue or a pull request against `master`.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.
