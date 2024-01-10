// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lcl-ping-cli",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(name: "LCLPing", path: "/Users/zhouzhennan/Desktop/research/LCLPing"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
        .package(url: "https://github.com/scottrhoyt/SwiftyTextTable.git", from: "0.9.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "lcl-ping-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "LCLPing",
                .product(name: "Yams", package: "Yams"),
                .product(name: "SwiftyTextTable", package: "SwiftyTextTable")
            ],
            path: "Sources"),
    ]
)
