// swift-tools-version: 6.0
import PackageDescription

/// DesignSystem — Shared UI extensions and reusable components.
/// Depends on CoreDomain.
let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    dependencies: [
        .package(path: "../CoreDomain"),
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: ["CoreDomain"]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"]
        ),
    ]
)
