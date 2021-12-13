// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LTHPasscodeViewController",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LTHPasscodeViewController",
            targets: ["LTHPasscodeViewController"]
        ),
    ],
    targets: [
        .target(
            name: "LTHPasscodeViewController_Swift",
            path: "LTHPasscodeViewController/Swift"
        ),
        .target(
            name: "LTHPasscodeViewController",
            dependencies: ["LTHPasscodeViewController_Swift"],
            path: ".",
            exclude: ["Demo", "CHANGELOG.md", "README.md", "LTHPasscodeViewController/Swift"],
            resources: [
                .process("Localizations/LTHPasscodeViewController.bundle"),
                .process("LICENSE.txt")
            ],
            publicHeadersPath: "LTHPasscodeViewController"
        )
    ]
)
