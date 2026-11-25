// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherCore",
    platforms: [
        .iOS(.v27),
        .macOS(.v26),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WeatherCore",
            targets: ["WeatherCore"]
        ),
    ],
    dependencies: [
        .package(path: "../Networking"),
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "WeatherCore",
            dependencies: [
                .product(name: "Networking", package: "Networking"),
                .product(name: "SWXMLHash", package: "SWXMLHash"),
            ]
        ),
        .testTarget(
            name: "WeatherCoreTests",
            dependencies: [
                "WeatherCore",
            ]
        ),
    ]
)
