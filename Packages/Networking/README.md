# Networking
A lightweight Swift Package providing a foundational layer for making network requests using the new `HTTPTypes` and `URLSession`. This package focuses on simplicity and clear separation of concerns, making it easy to define endpoints and execute requests. The package utilizes all new concurrency features introduced in Swift 6.2 for asynchronous code

## Main Components
- **`Endpoint` Protocol:** Define your API endpoints with properties like scheme, HTTP method, host, path, query items, and content type.
- **`URLSessionNetworkClient`:** A client built on `URLSession` for executing network requests based on your `Endpoint`definitions.

## Requirements
- iOS 18.0+ / macOS 26.0+   

## Installation
You can add `Networking` to your project using Swift Package Manager.
1. In Xcode, open your project.
2. Navigate to **File > Add Packages...**.
3. Enter the repository URL: `https://github.com/sheiaulis/Networking.git`.
4. Choose the desired version.

## Usage

### 1. Define Your Endpoint
Start by creating a struct or class that conforms to the `Endpoint` protocol.
```swift
import Foundation
import Networking
import HTTPTypes

struct GitHubUserEndpoint: Endpoint {
    var scheme: EndpointScheme = .https
    var httpMethod: HTTPMethod = .get
    var host: String = "api.github.com"
    var path: String? = "/users"
    var urlQueryItems: [URLQueryItem] = []
    var contentType: String? = "application/json"
}
```

### 2. Make a Network Request
Instantiate `URLSessionNetworkClient` and use it to fetch responses for your defined endpoints.

Swift

```swift
import Foundation
import Networking

Task {
    let client = URLSessionNetworkClient(urlSession: .shared)
    let usersEndpoint = GitHubUserEndpoint(username: "octocat")
    do {
        let response = try await client.fetchResponse(for: userEndpoint)
        // Process response.data
        print("Successfully fetched users!")
    } 
    catch {
        print("Error fetching user: \(error)")
    }
}
```

## Contributing
Contributions are welcome! If you have suggestions for improvements, new features, or bug fixes, feel free to open an issue or submit a pull request.

## License
This project is licensed under the MIT License. See the `LICENSE` file for more details.
