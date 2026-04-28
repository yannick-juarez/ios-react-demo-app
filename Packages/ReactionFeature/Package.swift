// swift-tools-version: 6.0
import PackageDescription

/// ReactionFeature — Complete reaction flow: permissions, main capture view, playback.
/// Depends on CoreDomain + DesignSystem + CameraFeature.
let package = Package(
    name: "ReactionFeature",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ReactionFeature", targets: ["ReactionFeature"]),
    ],
    dependencies: [
        .package(path: "../CoreDomain"),
        .package(path: "../DesignSystem"),
        .package(path: "../CameraFeature"),
        .package(path: "../AnalyticsKit"),
    ],
    targets: [
        .target(
            name: "ReactionFeature",
            dependencies: ["CoreDomain", "DesignSystem", "CameraFeature", "AnalyticsKit"]
        ),
        .testTarget(
            name: "ReactionFeatureTests",
            dependencies: ["ReactionFeature"]
        ),
    ]
)
