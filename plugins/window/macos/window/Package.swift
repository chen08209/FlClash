// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "window",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(name: "window", targets: ["window"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "window",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/window"
        )
    ]
)
