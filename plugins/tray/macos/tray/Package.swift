// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "tray",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(name: "tray", targets: ["tray"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "tray",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/tray"
        )
    ]
)
