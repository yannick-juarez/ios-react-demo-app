// swift-tools-version: 6.0
import PackageDescription

/// CameraFeature — Camera capture UI (capture button, live preview, confirm screen).
/// Depends on CoreDomain + DesignSystem.
let package = Package(
    name: "CameraFeature",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "CameraFeature", targets: ["CameraFeature"]),
    ],
    dependencies: [
        .package(path: "../CoreDomain"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "CameraFeature",
            dependencies: ["CoreDomain", "DesignSystem"]
        ),
        .testTarget(
            name: "CameraFeatureTests",
            dependencies: ["CameraFeature"]
        ),
    ]
)
