// swift-tools-version: 6.0
import PackageDescription

/// CoreInfrastructure — Concrete repositories, use cases and notification scheduler.
/// Depends on CoreDomain + CorePersistence.
let package = Package(
    name: "CoreInfrastructure",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "CoreInfrastructure", targets: ["CoreInfrastructure"]),
    ],
    dependencies: [
        .package(path: "../CoreDomain"),
        .package(path: "../CorePersistence"),
        .package(path: "../AnalyticsKit"),
    ],
    targets: [
        .target(
            name: "CoreInfrastructure",
            dependencies: ["CoreDomain", "CorePersistence", "AnalyticsKit"]
        ),
        .testTarget(
            name: "CoreInfrastructureTests",
            dependencies: ["CoreInfrastructure"]
        ),
    ]
)
