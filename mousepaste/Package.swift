// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Mousepaste",
    products: [
        .executable(
            name: "Mousepaste",
            targets: ["Mousepaste"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Mousepaste",
            dependencies: [],
            resources: [
                // .copy("Resources/image.png")
            ],
            linkerSettings: [
                // Howto use Info.plist:
                // https://gist.github.com/4np/f0e811bc0fdeb17186088c47d5bead5a
                // https://forums.swift.org/t/swift-package-manager-use-of-info-plist-use-for-apps/6532/13
      	        .unsafeFlags( ["-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "./Supporting/Info.plist"] )
            ]
        ),
    ]
)
