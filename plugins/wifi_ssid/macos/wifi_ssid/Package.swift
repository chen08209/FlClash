// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "wifi_ssid",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(name: "wifi-ssid", targets: ["wifi_ssid"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "wifi_ssid",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/wifi_ssid",
            linkerSettings: [
                .linkedFramework("CoreWLAN"),
                .linkedFramework("CoreLocation")
            ]
        )
    ]
)
