// swift-tools-version: 6.0
import PackageDescription

/// CoreDomain — Pure domain models and repository/use-case contracts.
/// No UI framework dependency. No persistence dependency.
let package = Package(
    name: "CoreDomain",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "CoreDomain", targets: ["CoreDomain"]),
    ],
    targets: [
        .target(name: "CoreDomain"),
        .testTarget(name: "CoreDomainTests", dependencies: ["CoreDomain"]),
    ]
)
