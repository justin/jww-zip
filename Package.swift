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
            cSettings: [
                // Use the system zlib API (not zlib-ng) for deflate and CRC-32.
                .define("HAVE_ZLIB"),
                .define("ZLIB_COMPAT"),
                // Legacy ZipCrypto password support (needs no external crypto backend).
                .define("HAVE_PKCRYPT"),
                // Build without a platform crypto backend (no WinZIP AES). Provides
                // mz_crypt_rand via mz_os_rand; ZipCrypto needs only rand + CRC-32.
                .define("MZ_ZIP_NO_CRYPTO"),
            ],
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
