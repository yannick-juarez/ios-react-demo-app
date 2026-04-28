// swift-tools-version: 6.0
import PackageDescription

/// ShareImportFeature — Share Extension controller and preview UI.
/// Depends on CoreDomain + CorePersistence + DesignSystem.
let package = Package(
    name: "ShareImportFeature",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ShareImportFeature", targets: ["ShareImportFeature"]),
    ],
    dependencies: [
        .package(path: "../CoreDomain"),
        .package(path: "../CorePersistence"),
        .package(path: "../DesignSystem"),
        .package(path: "../AnalyticsKit"),
    ],
    targets: [
        .target(
            name: "ShareImportFeature",
            dependencies: ["CoreDomain", "CorePersistence", "DesignSystem", "AnalyticsKit"]
        ),
        .testTarget(
            name: "ShareImportFeatureTests",
            dependencies: ["ShareImportFeature"]
        ),
    ]
)
