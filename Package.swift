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

        .library(name: "Sequence Primitive", targets: ["Sequence Primitive"]),
        .library(name: "Sequence Iterator", targets: ["Sequence Iterator"]),
        .library(name: "Sequence Protocol", targets: ["Sequence Protocol"]),
        .library(name: "Sequence Borrowing", targets: ["Sequence Borrowing"]),
        .library(name: "Sequence Span", targets: ["Sequence Span"]),

        .library(name: "Sequence Map", targets: ["Sequence Map"]),
        .library(name: "Sequence Filter", targets: ["Sequence Filter"]),
        .library(name: "Sequence Drop", targets: ["Sequence Drop"]),
        .library(name: "Sequence Prefix", targets: ["Sequence Prefix"]),

        .library(name: "Sequence ForEach", targets: ["Sequence ForEach"]),
        .library(name: "Sequence Satisfies", targets: ["Sequence Satisfies"]),
        .library(name: "Sequence Contains", targets: ["Sequence Contains"]),
        .library(name: "Sequence First", targets: ["Sequence First"]),
        .library(name: "Sequence Reduce", targets: ["Sequence Reduce"]),
        .library(name: "Sequence Hint", targets: ["Sequence Hint"]),

        .library(name: "Sequence Drain", targets: ["Sequence Drain"]),

        .library(
            name: "Sequence Difference",
            targets: ["Sequence Difference"]
        ),

        .library(
            name: "Sequence Standard Library Integration",
            targets: ["Sequence Standard Library Integration"]
        ),

        .library(name: "Sequence", targets: ["Sequence"]),

        .library(
            name: "Sequence Test Support",
            targets: ["Sequence Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-iterator.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-property.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Sequence Primitive",
            dependencies: []
        ),

        .target(
            name: "Sequence Iterator",
            dependencies: [
                "Sequence Primitive",
                .product(name: "Index", package: "swift-index"),
            ]
        ),

        .target(
            name: "Sequence Protocol",
            dependencies: [
                "Sequence Primitive",
                .product(name: "Iterator Protocol", package: "swift-iterator"),
                .product(name: "Index", package: "swift-index"),
            ]
        ),

        .target(
            name: "Sequence Borrowing",
            dependencies: [
                "Sequence Iterator",
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Sequence Span",
            dependencies: [
                "Sequence Protocol",
                "Sequence Borrowing",
                .product(name: "Property", package: "swift-property"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Sequence Map",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),
        .target(
            name: "Sequence Filter",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Sequence Drop",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Index", package: "swift-index"),
            ]
        ),

        .target(
            name: "Sequence Prefix",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Index", package: "swift-index"),
            ]
        ),

        .target(
            name: "Sequence ForEach",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Property", package: "swift-property"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),

        .target(
            name: "Sequence Satisfies",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Property", package: "swift-property"),
            ]
        ),

        .target(
            name: "Sequence Contains",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Property", package: "swift-property"),
            ]
        ),

        .target(
            name: "Sequence First",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Property", package: "swift-property"),
            ]
        ),

        .target(
            name: "Sequence Reduce",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Property", package: "swift-property"),
            ]
        ),

        .target(
            name: "Sequence Hint",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Property", package: "swift-property"),
                .product(name: "Index", package: "swift-index"),
                .product(
                    name: "Cardinal Standard Library Integration",
                    package: "swift-cardinal"
                ),
            ]
        ),

        .target(
            name: "Sequence Drain",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Property", package: "swift-property"),
            ]
        ),

        .target(
            name: "Sequence Difference",
            dependencies: [
                "Sequence Protocol",
                .product(name: "Index", package: "swift-index"),
            ]
        ),

        .target(
            name: "Sequence Standard Library Integration",
            dependencies: [
                "Sequence Protocol",
                "Sequence Borrowing",
                .product(name: "Index", package: "swift-index"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Sequence",
            dependencies: [
                "Sequence Primitive",
                "Sequence Iterator",
                "Sequence Protocol",
                "Sequence Borrowing",
                "Sequence Span",
                "Sequence Map",
                "Sequence Filter",
                "Sequence Drop",
                "Sequence Prefix",
                "Sequence ForEach",
                "Sequence Satisfies",
                "Sequence Contains",
                "Sequence First",
                "Sequence Reduce",
                "Sequence Hint",
                "Sequence Drain",
                "Sequence Difference",
                "Sequence Standard Library Integration",
            ]
        ),

        .target(
            name: "Sequence Test Support",
            dependencies: [
                "Sequence",
                .product(name: "Index Test Support", package: "swift-index"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Sequence Primitive Tests",
            dependencies: ["Sequence Primitive", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Iterator Tests",
            dependencies: ["Sequence Iterator", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Protocol Tests",
            dependencies: ["Sequence Protocol", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Borrowing Tests",
            dependencies: ["Sequence Borrowing", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Span Tests",
            dependencies: ["Sequence Span", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Map Tests",
            dependencies: ["Sequence Map", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Filter Tests",
            dependencies: ["Sequence Filter", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Drop Tests",
            dependencies: ["Sequence Drop", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Prefix Tests",
            dependencies: ["Sequence Prefix", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence ForEach Tests",
            dependencies: ["Sequence ForEach", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Satisfies Tests",
            dependencies: ["Sequence Satisfies", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Contains Tests",
            dependencies: ["Sequence Contains", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence First Tests",
            dependencies: ["Sequence First", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Reduce Tests",
            dependencies: ["Sequence Reduce", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Hint Tests",
            dependencies: ["Sequence Hint", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Drain Tests",
            dependencies: ["Sequence Drain", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Difference Tests",
            dependencies: ["Sequence Difference", "Sequence Test Support"]
        ),

        .testTarget(
            name: "Sequence Standard Library Integration Tests",
            dependencies: [
                "Sequence Standard Library Integration",
                "Sequence Test Support",
            ]
        ),

        .testTarget(
            name: "Sequence Composition Tests",
            dependencies: [
                "Sequence Map",
                "Sequence Filter",
                "Sequence Drop",
                "Sequence Prefix",
                "Sequence Hint",
                "Sequence Test Support",
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
