// swift-tools-version: 6.2

// https://theswiftdev.com/the-swift-package-manifest-file/


import PackageDescription


let package = Package(
    name: "DiscreteStepSlider",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "DiscreteStepSlider",
            targets: ["DiscreteStepSlider"]
        ),
    ],
    dependencies: [
        .package(path: "../preview-utilities"),
    ],
    targets: [
        .target(
            name: "DiscreteStepSlider",
            dependencies: [
                .product(name: "PreviewUtilities", package: "preview-utilities")
            ],
            path: "sources",
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]

        ),
        .testTarget(
            name: "DiscreteStepSliderTests",
            dependencies: ["DiscreteStepSlider"],
            path: "tests",
        ),
    ]
)

// Target settings.
for target in package.targets {
    target.swiftSettings?.append(contentsOf: [
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
}
