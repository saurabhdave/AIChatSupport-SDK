// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AIChatSupport",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "AIChatSupport", targets: ["AIChatSupport"])
    ],
    targets: [
        .target(
            name: "AIChatSupport",
            path: "Sources/AIChatSupport",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "AIChatSupportTests",
            dependencies: ["AIChatSupport"],
            path: "Tests/AIChatSupportTests"
        )
    ]
)
