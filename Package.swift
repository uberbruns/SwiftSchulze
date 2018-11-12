// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Schulze",
    products: [
        .executable(name: "schulze", targets: ["SchulzeCLI"]),
        .library(name: "SchulzeLibrary", targets: ["SchulzeLibrary"]),
        ],
    dependencies: [
        .package(url: "https://github.com/kareman/Moderator.git", from: "0.5.0"),
        ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SchulzeCLI",
            dependencies: ["SchulzeLibrary", "Moderator"]),
        .target(
            name: "SchulzeLibrary",
            dependencies: []),
        .testTarget(
            name: "SchulzeTests",
            dependencies: ["SchulzeLibrary"]),
        ]
)

