// swift-tools-version: 6.0
import PackageDescription

/// CorePersistence — DTO, mappers and local storage implementations.
/// Depends on CoreDomain only.
let package = Package(
    name: "CorePersistence",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "CorePersistence", targets: ["CorePersistence"]),
    ],
    dependencies: [
        .package(path: "../CoreDomain"),
    ],
    targets: [
        .target(
            name: "CorePersistence",
            dependencies: ["CoreDomain"]
        ),
        .testTarget(
            name: "CorePersistenceTests",
            dependencies: ["CorePersistence"]
        ),
    ]
)
