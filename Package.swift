// swift-tools-version: 6.2

// https://theswiftdev.com/the-swift-package-manifest-file/


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
//        .package(path: "../preview-utilities")
        .package(url: "../preview-utilities", branch: "initial-tagged-release")
//        .package(url: "https://github.com/lopsae/preview-utilities.git", branch: "initial-tagged-release")
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
            path: "tests",
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
        .enableUpcomingFeature("InferIsolatedConformances")
    ])
    target.swiftSettings = settings
}
