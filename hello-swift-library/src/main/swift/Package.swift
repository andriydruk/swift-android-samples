// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hello-swift-library",
    products: [
        .library(name: "hello-swift-library", type: .dynamic, targets: ["hello-swift-library"]),
    ],
    targets: [
        .target(name: "hello-swift-library")
    ]
)
