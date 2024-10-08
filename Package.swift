// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lcl-cli",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/Local-Connectivity-Lab/lcl-ping.git", from: "1.0.3"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.3"),
        .package(url: "https://github.com/scottrhoyt/SwiftyTextTable.git", from: "0.9.0"),
        .package(url: "https://github.com/Local-Connectivity-Lab/lcl-auth.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.73.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.25.0"),
        .package(url: "https://github.com/Local-Connectivity-Lab/lcl-speedtest.git", from: "1.0.4"),
        .package(url: "https://github.com/johnnzhou/ANSITerminal.git", from: "0.0.4"),
    ],
    targets: [
        .executableTarget(
            name: "lcl",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "LCLPing", package: "lcl-ping"),
                .product(name: "SwiftyTextTable", package: "SwiftyTextTable"),
                .product(name: "LCLAuth", package: "lcl-auth"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "LCLSpeedtest", package: "lcl-speedtest"),
                .product(name: "ANSITerminal", package: "ANSITerminal")
            ],
            path: "Sources")
    ]
)
