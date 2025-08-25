// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AndroidNativeAppGlue",
    products: [
        .library(name: "AndroidNativeAppGlue", targets: ["AndroidNativeAppGlue"]),
        .library(name: "AndroidOpenGL", targets: ["AndroidOpenGL"])
    ],
    targets: [
        .target(name: "AndroidNativeAppGlue"),
        .target(name: "AndroidOpenGL")
    ],
    cxxLanguageStandard: .cxx98
)
