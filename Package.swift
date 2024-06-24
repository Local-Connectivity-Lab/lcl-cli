// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lcl-cli",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/Local-Connectivity-Lab/lcl-ping.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.3"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
        .package(url: "https://github.com/scottrhoyt/SwiftyTextTable.git", from: "0.9.0"),
        .package(url: "https://github.com/johnnzhou/lcl-auth.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.63.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.25.0"),
        .package(url: "https://github.com/johnnzhou/lcl-speedtest.git", branch: "main"),
        .package(url: "https://github.com/pakLebah/ANSITerminal", from: "0.0.3")
    ],
    targets: [
        .executableTarget(
            name: "lcl",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "LCLPing", package: "lcl-ping"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "SwiftyTextTable", package: "SwiftyTextTable"),
                .product(name: "LCLAuth", package: "lcl-auth"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "LCLSpeedTest", package: "lcl-speedtest"),
                .product(name: "ANSITerminal", package: "ANSITerminal")
            ],
            path: "Sources")
    ]
)
