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
        .library(name: "Sequence", targets: ["Sequence"]),
        .library(name: "Sequence Standard Library Integration", targets: ["Sequence Standard Library Integration"]),
        .library(name: "Sequence Foundation Library Integration", targets: ["Sequence Foundation Library Integration"]),
        .library(name: "Sequence Test Support", targets: ["Sequence Test Support"]),
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
            dependencies: [
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Property", package: "swift-property"),
                .product(name: "Carrier", package: "swift-carrier"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Cardinal Standard Library Integration", package: "swift-cardinal"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Ordinal Standard Library Integration", package: "swift-ordinal"),
            ],
            path: "Sources/Sequence"
        ),
        .target(
            name: "Sequence Standard Library Integration",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Carrier", package: "swift-carrier"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .target(name: "Sequence"),
            ],
            path: "Sources/Sequence Standard Library Integration"
        ),
        .target(
            name: "Sequence Foundation Library Integration",
            dependencies: [
                .target(name: "Sequence"),
                .target(name: "Sequence Standard Library Integration"),
            ],
            path: "Sources/Sequence Foundation Library Integration"
        ),
        .target(
            name: "Sequence Test Support",
            dependencies: [
                .target(name: "Sequence"),
                .product(name: "Carrier", package: "swift-carrier"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Index Test Support", package: "swift-index"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Sequence Tests",
            dependencies: [
                .target(name: "Sequence"),
                .target(name: "Sequence Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Ordinal Standard Library Integration", package: "swift-ordinal"),
                .target(name: "Sequence Standard Library Integration"),
                .target(name: "Sequence Foundation Library Integration"),
            ],
            path: "Tests/Sequence Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("BuiltinModule"),
    ]
}
