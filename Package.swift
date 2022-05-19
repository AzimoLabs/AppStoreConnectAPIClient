// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppStoreManager",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "AppStoreManagerAuthorization",
            targets: ["AppStoreManagerAuthorization"]),

        .library(
            name: "AppStoreManager",
            targets: ["AppStoreManager"]),
        .executable(
            name: "appStoreManagerShell",
            targets: ["AppStoreManagerShell"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "1.1.2"))
    ],
    targets: [
        .target(
            name: "AppStoreManager"),
        .target(
            name: "AppStoreManagerAuthorization"),
        .executableTarget(
            name: "AppStoreManagerShell",
            dependencies: [
                "AppStoreManagerAuthorization",
                "AppStoreManager",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .testTarget(
            name: "AppStoreManagerTests",
            dependencies: [
                "AppStoreManager",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
    ]
)
