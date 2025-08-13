// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hello-swift-callback",
    products: [
        .library(name: "hello-swift-callback", type: .dynamic, targets: ["hello-swift-callback"]),
    ],
    targets: [
        .target(name: "hello-swift-callback")
    ]
)
