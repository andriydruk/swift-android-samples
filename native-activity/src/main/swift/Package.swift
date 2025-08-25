// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "native-activity",
    products: [
        .library(name: "native-activity", type: .dynamic, targets: ["native-activity"]),
    ],
    dependencies: [
        .package(path: "../../../../native-app-glue")
    ],
    targets: [
        .target(
            name: "native-activity",
            dependencies: [
                .product(name: "AndroidNativeAppGlue", package: "native-app-glue"),
                .product(name: "AndroidOpenGL", package: "native-app-glue")
            ],
            linkerSettings: [
                .linkedLibrary("android"),
                .linkedLibrary("EGL"),
                .linkedLibrary("GLESv1_CM"),
                .linkedLibrary("log")
            ]
        )
    ]
)
