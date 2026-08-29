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
            url: "https://github.com/swift-atoms/swift-iterator.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-property.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ordinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-carrier.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Sequence",
            dependencies: []
        ),

        .target(
            name: "Sequence Iterator",
            dependencies: [
                .target(name: "Sequence"),
            ]
        ),

        .target(
            name: "Sequence Protocol",
            dependencies: [
                .target(name: "Sequence"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
            ]
        ),

        .target(
            name: "Sequence Borrowing",
            dependencies: [
                .target(name: "Sequence Iterator"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Sequence Span",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .target(name: "Sequence Borrowing"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Sequence Map",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),
        .target(
            name: "Sequence Filter",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Sequence Drop",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Cardinal Subtract", package: "swift-cardinal"),
                .product(name: "Carrier Protocol", package: "swift-carrier"),
            ]
        ),

        .target(
            name: "Sequence Prefix",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Cardinal Subtract", package: "swift-cardinal"),
                .product(name: "Carrier Protocol", package: "swift-carrier"),
            ]
        ),

        .target(
            name: "Sequence ForEach",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .target(name: "Sequence Borrowing"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),

        .target(
            name: "Sequence Satisfies",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .target(name: "Sequence Borrowing"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
            ]
        ),

        .target(
            name: "Sequence Contains",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .target(name: "Sequence Borrowing"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),

        .target(
            name: "Sequence First",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .target(name: "Sequence Borrowing"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),

        .target(
            name: "Sequence Reduce",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .target(name: "Sequence Borrowing"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),

        .target(
            name: "Sequence Hint",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(
                    name: "Cardinal Standard Library Integration",
                    package: "swift-cardinal"
                ),
            ]
        ),

        .target(
            name: "Sequence Drain",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Property Inout", package: "swift-property"),
            ]
        ),

        .target(
            name: "Sequence Difference",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(
                    name: "Cardinal Standard Library Integration",
                    package: "swift-cardinal"
                ),
                .product(name: "Cardinal Subtract", package: "swift-cardinal"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Ordinal Protocol", package: "swift-ordinal"),
                .product(
                    name: "Ordinal Standard Library Integration",
                    package: "swift-ordinal"
                ),
                .product(name: "Ordinal Successor", package: "swift-ordinal"),
            ]
        ),

        .target(
            name: "Sequence Standard Library Integration",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Carrier Protocol", package: "swift-carrier"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Ordinal", package: "swift-ordinal"),
            ]
        ),

        .target(
            name: "Sequence Test Support",
            dependencies: [
                .target(name: "Sequence"),
                .target(name: "Sequence Protocol"),
                .target(name: "Sequence Borrowing"),
                .target(name: "Sequence Drain"),
                .product(name: "Carrier Protocol", package: "swift-carrier"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Index Test Support", package: "swift-index"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Sequence Tests",
            dependencies: [.target(name: "Sequence"), .target(name: "Sequence Test Support")]
        ),

        .testTarget(
            name: "Sequence Iterator Tests",
            dependencies: [.target(name: "Sequence Iterator"), .target(name: "Sequence Test Support")]
        ),

        .testTarget(
            name: "Sequence Protocol Tests",
            dependencies: [
                .target(name: "Sequence Protocol"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
            ]
        ),

        .testTarget(
            name: "Sequence Borrowing Tests",
            dependencies: [.target(name: "Sequence Borrowing"), .target(name: "Sequence Test Support")]
        ),

        .testTarget(
            name: "Sequence Span Tests",
            dependencies: [.target(name: "Sequence Span"), .target(name: "Sequence Test Support")]
        ),

        .testTarget(
            name: "Sequence Map Tests",
            dependencies: [
                .target(name: "Sequence Filter"),
                .target(name: "Sequence Hint"),
                .target(name: "Sequence Map"),
                .target(name: "Sequence Test Support"),
            ]
        ),

        .testTarget(
            name: "Sequence Filter Tests",
            dependencies: [
                .target(name: "Sequence Filter"),
                .target(name: "Sequence Hint"),
                .target(name: "Sequence Test Support"),
            ]
        ),

        .testTarget(
            name: "Sequence Drop Tests",
            dependencies: [
                .target(name: "Sequence Drop"),
                .target(name: "Sequence Hint"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
            ]
        ),

        .testTarget(
            name: "Sequence Prefix Tests",
            dependencies: [
                .target(name: "Sequence Hint"),
                .target(name: "Sequence Prefix"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
            ]
        ),

        .testTarget(
            name: "Sequence ForEach Tests",
            dependencies: [
                .target(name: "Sequence ForEach"),
                .target(name: "Sequence Borrowing"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .testTarget(
            name: "Sequence Satisfies Tests",
            dependencies: [
                .target(name: "Sequence Satisfies"),
                .target(name: "Sequence Borrowing"),
                .target(name: "Sequence Test Support"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .testTarget(
            name: "Sequence Contains Tests",
            dependencies: [
                .target(name: "Sequence Contains"),
                .target(name: "Sequence Borrowing"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .testTarget(
            name: "Sequence First Tests",
            dependencies: [
                .target(name: "Sequence First"),
                .target(name: "Sequence Borrowing"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .testTarget(
            name: "Sequence Reduce Tests",
            dependencies: [
                .target(name: "Sequence Reduce"),
                .target(name: "Sequence Borrowing"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
            ]
        ),

        .testTarget(
            name: "Sequence Hint Tests",
            dependencies: [.target(name: "Sequence Hint"), .target(name: "Sequence Test Support")]
        ),

        .testTarget(
            name: "Sequence Drain Tests",
            dependencies: [.target(name: "Sequence Drain"), .target(name: "Sequence Test Support")]
        ),

        .testTarget(
            name: "Sequence Difference Tests",
            dependencies: [
                .target(name: "Sequence Difference"),
                .target(name: "Sequence Hint"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(
                    name: "Ordinal Standard Library Integration",
                    package: "swift-ordinal"
                ),
            ]
        ),

        .testTarget(
            name: "Sequence Standard Library Integration Tests",
            dependencies: [
                .target(name: "Sequence Standard Library Integration"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
            ]
        ),

        .testTarget(
            name: "Sequence Composition Tests",
            dependencies: [
                .target(name: "Sequence Map"),
                .target(name: "Sequence Filter"),
                .target(name: "Sequence Drop"),
                .target(name: "Sequence Prefix"),
                .target(name: "Sequence Hint"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
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
