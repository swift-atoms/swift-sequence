// swift-tools-version: 6.2

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
        .library(
            name: "Sequence Primitives",
            targets: ["Sequence Primitives"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-property-primitives"),
        .package(path: "../swift-index-primitives"),
    ],
    targets: [
        .target(
            name: "Sequence Primitives Core",
            dependencies: [
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),
        .target(
            name: "Sequence Primitives",
            dependencies: [
                "Sequence Primitives Core",
                "Sequence Primitives Standard Library Integration",
            ]
        ),
        .target(
            name: "Sequence Primitives Standard Library Integration",
            dependencies: [
                "Sequence Primitives Core",
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
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("BuiltinModule"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
