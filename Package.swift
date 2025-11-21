// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

// https://theswiftdev.com/the-swift-package-manifest-file/


import PackageDescription


let package = Package(
    name: "DiscreteStepSlider",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DiscreteStepSlider",
            targets: ["DiscreteStepSlider"]
        ),
    ],
    dependencies: [
        .package(path: "../preview-utilities"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DiscreteStepSlider",
            dependencies: [
                .product(name: "PreviewUtilities", package: "preview-utilities")
            ],
            path: "sources"
        ),
        .testTarget(
            name: "DiscreteStepSliderTests",
            dependencies: ["DiscreteStepSlider"],
            path: "tests",
        ),
    ]
)
