// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-sequence",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Sequence",
            targets: ["Sequence"]
        ),
        .library(
            name: "Sequence Standard Library Integration",
            targets: ["Sequence Standard Library Integration"]
        ),
        .library(
            name: "Sequence Apple Foundation Integration",
            targets: ["Sequence Apple Foundation Integration"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-iterator.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-index.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Sequence",
            dependencies: [
                .product(name: "Iterator Protocol", package: "swift-iterator"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Index", package: "swift-index"),
            ]
        ),
        .target(
            name: "Sequence Standard Library Integration",
            dependencies: ["Sequence"]
        ),
        .target(
            name: "Sequence Apple Foundation Integration",
            dependencies: [
                "Sequence",
                "Sequence Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Sequence Tests",
            dependencies: ["Sequence"]
        ),
        .testTarget(
            name: "Sequence Standard Library Integration Tests",
            dependencies: [
                "Sequence",
                "Sequence Standard Library Integration",
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
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("BuiltinModule")
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
