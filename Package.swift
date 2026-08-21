// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-sequence-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(name: "Sequence Primitive", targets: ["Sequence Primitive"]),
        .library(name: "Sequence Iterator Primitives", targets: ["Sequence Iterator Primitives"]),
        .library(name: "Sequence Protocol Primitives", targets: ["Sequence Protocol Primitives"]),
        .library(name: "Sequence Borrowing Primitives", targets: ["Sequence Borrowing Primitives"]),
        .library(name: "Sequence Span Primitives", targets: ["Sequence Span Primitives"]),

        .library(name: "Sequence Map Primitives", targets: ["Sequence Map Primitives"]),
        .library(name: "Sequence Filter Primitives", targets: ["Sequence Filter Primitives"]),
        .library(name: "Sequence Drop Primitives", targets: ["Sequence Drop Primitives"]),
        .library(name: "Sequence Prefix Primitives", targets: ["Sequence Prefix Primitives"]),

        .library(name: "Sequence ForEach Primitives", targets: ["Sequence ForEach Primitives"]),
        .library(name: "Sequence Satisfies Primitives", targets: ["Sequence Satisfies Primitives"]),
        .library(name: "Sequence Contains Primitives", targets: ["Sequence Contains Primitives"]),
        .library(name: "Sequence First Primitives", targets: ["Sequence First Primitives"]),
        .library(name: "Sequence Reduce Primitives", targets: ["Sequence Reduce Primitives"]),
        .library(name: "Sequence Hint Primitives", targets: ["Sequence Hint Primitives"]),

        .library(name: "Sequence Drain Primitives", targets: ["Sequence Drain Primitives"]),

        .library(
            name: "Sequence Difference Primitives",
            targets: ["Sequence Difference Primitives"]
        ),

        .library(
            name: "Sequence Primitives Standard Library Integration",
            targets: ["Sequence Primitives Standard Library Integration"]
        ),

        .library(name: "Sequence Primitives", targets: ["Sequence Primitives"]),

        .library(
            name: "Sequence Primitives Test Support",
            targets: ["Sequence Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-iterator-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-either-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-property-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-index-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-cardinal-primitives.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Sequence Primitive",
            dependencies: []
        ),

        .target(
            name: "Sequence Iterator Primitives",
            dependencies: [
                "Sequence Primitive",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),

        .target(
            name: "Sequence Protocol Primitives",
            dependencies: [
                "Sequence Primitive",
                .product(name: "Iterator Protocol", package: "swift-iterator-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),

        .target(
            name: "Sequence Borrowing Primitives",
            dependencies: [
                "Sequence Iterator Primitives",
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
            ]
        ),

        .target(
            name: "Sequence Span Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                "Sequence Borrowing Primitives",
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
            ]
        ),

        .target(
            name: "Sequence Map Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Iterator Protocol", package: "swift-iterator-primitives"),
            ]
        ),
        .target(
            name: "Sequence Filter Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Iterator Protocol", package: "swift-iterator-primitives"),
            ]
        ),

        .target(
            name: "Sequence Drop Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),

        .target(
            name: "Sequence Prefix Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),

        .target(
            name: "Sequence ForEach Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
            ]
        ),

        .target(
            name: "Sequence Satisfies Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),

        .target(
            name: "Sequence Contains Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),

        .target(
            name: "Sequence First Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),

        .target(
            name: "Sequence Reduce Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),

        .target(
            name: "Sequence Hint Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(
                    name: "Cardinal Primitives Standard Library Integration",
                    package: "swift-cardinal-primitives"
                ),
            ]
        ),

        .target(
            name: "Sequence Drain Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),

        .target(
            name: "Sequence Difference Primitives",
            dependencies: [
                "Sequence Protocol Primitives",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),

        .target(
            name: "Sequence Primitives Standard Library Integration",
            dependencies: [
                "Sequence Protocol Primitives",
                "Sequence Borrowing Primitives",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
            ]
        ),

        .target(
            name: "Sequence Primitives",
            dependencies: [
                "Sequence Primitive",
                "Sequence Iterator Primitives",
                "Sequence Protocol Primitives",
                "Sequence Borrowing Primitives",
                "Sequence Span Primitives",
                "Sequence Map Primitives",
                "Sequence Filter Primitives",
                "Sequence Drop Primitives",
                "Sequence Prefix Primitives",
                "Sequence ForEach Primitives",
                "Sequence Satisfies Primitives",
                "Sequence Contains Primitives",
                "Sequence First Primitives",
                "Sequence Reduce Primitives",
                "Sequence Hint Primitives",
                "Sequence Drain Primitives",
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
            name: "Sequence Primitive Tests",
            dependencies: ["Sequence Primitive", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Iterator Primitives Tests",
            dependencies: ["Sequence Iterator Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Protocol Primitives Tests",
            dependencies: ["Sequence Protocol Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Borrowing Primitives Tests",
            dependencies: ["Sequence Borrowing Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Span Primitives Tests",
            dependencies: ["Sequence Span Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Map Primitives Tests",
            dependencies: ["Sequence Map Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Filter Primitives Tests",
            dependencies: ["Sequence Filter Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Drop Primitives Tests",
            dependencies: ["Sequence Drop Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Prefix Primitives Tests",
            dependencies: ["Sequence Prefix Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence ForEach Primitives Tests",
            dependencies: ["Sequence ForEach Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Satisfies Primitives Tests",
            dependencies: ["Sequence Satisfies Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Contains Primitives Tests",
            dependencies: ["Sequence Contains Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence First Primitives Tests",
            dependencies: ["Sequence First Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Reduce Primitives Tests",
            dependencies: ["Sequence Reduce Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Hint Primitives Tests",
            dependencies: ["Sequence Hint Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Drain Primitives Tests",
            dependencies: ["Sequence Drain Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Difference Primitives Tests",
            dependencies: ["Sequence Difference Primitives", "Sequence Primitives Test Support"]
        ),

        .testTarget(
            name: "Sequence Primitives Standard Library Integration Tests",
            dependencies: [
                "Sequence Primitives Standard Library Integration",
                "Sequence Primitives Test Support",
            ]
        ),

        .testTarget(
            name: "Sequence Composition Tests",
            dependencies: [
                "Sequence Map Primitives",
                "Sequence Filter Primitives",
                "Sequence Drop Primitives",
                "Sequence Prefix Primitives",
                "Sequence Hint Primitives",
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
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("BuiltinModule")
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
