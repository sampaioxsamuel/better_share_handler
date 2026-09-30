// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "better_share_handler",
    platforms: [
        .iOS("14.0"),
    ],
    products: [
        .library(name: "better-share-handler", targets: ["better_share_handler"]),
        .library(name: "better-share-handler-models", targets: ["better_share_handler_models"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "better_share_handler",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "better_share_handler_models",
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
        .target(
            name: "better_share_handler_models",
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
