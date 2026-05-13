// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-sequence-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        // MARK: - Sub-targets
        .library(
            name: "Sequence Primitives Core",
            targets: ["Sequence Primitives Core"]
        ),
        .library(
            name: "Sequence Consuming Primitives",
            targets: ["Sequence Consuming Primitives"]
        ),
        .library(
            name: "Sequence Lazy Primitives",
            targets: ["Sequence Lazy Primitives"]
        ),
        .library(
            name: "Sequence Terminal Primitives",
            targets: ["Sequence Terminal Primitives"]
        ),
        .library(
            name: "Sequence Primitives Standard Library Integration",
            targets: ["Sequence Primitives Standard Library Integration"]
        ),
        .library(
            name: "Sequence Difference Primitives",
            targets: ["Sequence Difference Primitives"]
        ),

        // MARK: - Umbrella
        .library(
            name: "Sequence Primitives",
            targets: ["Sequence Primitives"]
        ),

        // MARK: - Test Support
        .library(
            name: "Sequence Primitives Test Support",
            targets: ["Sequence Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-property-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Sequence Primitives Core",
            dependencies: [
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),

        // MARK: - Consuming
        .target(
            name: "Sequence Consuming Primitives",
            dependencies: [
                "Sequence Primitives Core",
            ]
        ),

        // MARK: - Lazy
        .target(
            name: "Sequence Lazy Primitives",
            dependencies: [
                "Sequence Primitives Core",
            ]
        ),

        // MARK: - Terminal
        .target(
            name: "Sequence Terminal Primitives",
            dependencies: [
                "Sequence Primitives Core",
                "Sequence Consuming Primitives",
            ]
        ),

        // MARK: - Difference
        .target(
            name: "Sequence Difference Primitives",
            dependencies: [
                "Sequence Primitives Core",
            ]
        ),

        // MARK: - Standard Library Integration
        .target(
            name: "Sequence Primitives Standard Library Integration",
            dependencies: [
                "Sequence Primitives Core",
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Sequence Primitives",
            dependencies: [
                "Sequence Primitives Core",
                "Sequence Consuming Primitives",
                "Sequence Lazy Primitives",
                "Sequence Terminal Primitives",
                "Sequence Difference Primitives",
                "Sequence Primitives Standard Library Integration",
            ]
        ),
        .target(
            name: "Sequence Primitives Test Support",
            dependencies: [
                "Sequence Primitives",
                .product(name: "Index Primitives Test Support", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Sequence Primitives Tests",
            dependencies: [
                "Sequence Primitives",
                "Sequence Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("BuiltinModule"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
