// swift-tools-version: 6.0
import PackageDescription

/// ShareImportFeature — Share Extension controller and preview UI.
/// Depends on CoreDomain + CoreInfrastructure + DesignSystem.
let package = Package(
    name: "ShareImportFeature",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ShareImportFeature", targets: ["ShareImportFeature"]),
    ],
    dependencies: [
        .package(path: "../CoreDomain"),
        .package(path: "../CoreInfrastructure"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "ShareImportFeature",
            dependencies: ["CoreDomain", "CoreInfrastructure", "DesignSystem"]
        ),
        .testTarget(
            name: "ShareImportFeatureTests",
            dependencies: ["ShareImportFeature"]
        ),
    ]
)
