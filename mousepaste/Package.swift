// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Mousepaste",
    platforms: [
        // .macCatalyst(.v13)
        .macOS(.v12)
    ],
    products: [
        .library(name: "Logging", targets: ["Logging"]),
        .library(name: "Appster", targets: ["Appster"]),
        .executable(name: "Mousepaste", targets: ["Mousepaste"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.1.2"
        )
    ],

    targets: [
        .target(name: "Logging",
            resources: [.copy("./README.md")]
        ),
        .target(name: "Appster",
            dependencies: ["Logging"],
            resources: [.copy("./README.md")]
        ),
        .executableTarget(
            name: "Mousepaste",
            dependencies: [
                "Logging",
                "Appster",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .copy("./Resources/Mousepaste.svg"),
                .copy("./Resources/Mousepaste.icns"),
            ],
            linkerSettings: [
                // Howto use Info.plist:
                // https://gist.github.com/4np/f0e811bc0fdeb17186088c47d5bead5a
                // https://forums.swift.org/t/swift-package-manager-use-of-info-plist-use-for-apps/6532/13
      	        // .unsafeFlags( [
                //     "-Xlinker", "-sectcreate",
                //     "-Xlinker", "-no-link-objc-runtime",
                //     "-Xlinker", "__TEXT",
                //     "-Xlinker", "__info_plist",
                //     "-Xlinker", "./Supporting/Info.plist"] )
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
