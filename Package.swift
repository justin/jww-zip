// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Zip",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .library(name: "Zip", targets: ["Zip"])
    ],
    targets: [
        .target(
            name: "Minizip",
            linkerSettings: [
                .linkedLibrary("z")
            ]),
        .target(
            name: "Zip",
            dependencies: ["Minizip"]),
        .testTarget(
            name: "ZipTests",
            dependencies: ["Zip"],
            resources: [.process("Resources")]),
    ],
    swiftLanguageModes: [
        .v5,
        .v6
    ]
)
