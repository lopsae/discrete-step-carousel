// swift-tools-version: 6.2


import PackageDescription


let package = Package(
    name: "DiscreteStepCarousel",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "DiscreteStepCarousel",
            targets: ["DiscreteStepCarousel"]
        ),
    ],
    dependencies: [
//        .package(url: "https://github.com/lopsae/preview-utilities.git", "0.4.0"..<"1.0.0"),
        .package(url: "https://github.com/lopsae/preview-utilities.git", branch: "feature/debug-alignment-guide-modifier"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "DiscreteStepCarousel",
            dependencies: [
                .product(name: "PreviewUtilities", package: "preview-utilities")
            ],
            path: "sources"
        ),
        .testTarget(
            name: "DiscreteStepCarouselTests",
            dependencies: ["DiscreteStepCarousel"],
            path: "unit-tests",
        ),
    ]
)

// Target settings.
for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(contentsOf: [
        // https://developer.apple.com/documentation/xcode/build-settings-reference#Approachable-Concurrency
        // https://developer.apple.com/documentation/xcode/build-settings-reference#Approachable-Concurrency
        // https://useyourloaf.com/blog/approachable-concurrency-in-swift-packages/
        // https://www.avanderlee.com/concurrency/approachable-concurrency-in-swift-6-2-a-clear-guide/

        .defaultIsolation(MainActor.self),

        // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),

        // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0470-isolated-conformances.md
        .enableUpcomingFeature("InferIsolatedConformances"),

        // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0409-access-level-on-imports.md
//        .enableUpcomingFeature("InternalImportsByDefault"),
    ])
    target.swiftSettings = settings
}
