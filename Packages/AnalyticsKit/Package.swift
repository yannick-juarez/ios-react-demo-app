// swift-tools-version: 6.0
import PackageDescription

/// AnalyticsKit — Pluggable analytics layer.
///
/// Core target has zero external dependencies. To enable Amplitude:
/// 1. Uncomment the Amplitude dependency below.
/// 2. Uncomment the `AmplitudeSwift` dependency in the AnalyticsKit target.
/// 3. Uncomment the implementation body in `AmplitudeAnalyticsProvider.swift`.
let package = Package(
    name: "AnalyticsKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "AnalyticsKit", targets: ["AnalyticsKit"]),
    ],
    dependencies: [
        // Uncomment to enable real Amplitude integration:
        // .package(url: "https://github.com/amplitude/Amplitude-Swift", from: "1.7.0"),
    ],
    targets: [
        .target(
            name: "AnalyticsKit",
            dependencies: [
                // Uncomment when Amplitude dep above is enabled:
                // .product(name: "AmplitudeSwift", package: "Amplitude-Swift"),
            ]
        ),
        .testTarget(
            name: "AnalyticsKitTests",
            dependencies: ["AnalyticsKit"]
        ),
    ]
)
