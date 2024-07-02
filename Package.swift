// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WhyPeopleKit",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v16),
    .watchOS(.v9),
    .macCatalyst(.v16)
  ],
  products: [
    .library(name: "WPFoundation", targets: ["WPFoundation"]),
    .library(name: "WPSilentModeSwitch", targets: ["WPSilentModeSwitch"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.11.2"),
    .package(url: "https://github.com/pointfreeco/swift-clocks", from: "1.0.2"),
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.13.0"),
    .package(url: "https://github.com/MobileNativeFoundation/Kronos", from: "4.2.2"),
    .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.2")
  ],
  targets: [
    .target(name: "WPFoundation"),
    .testTarget(name: "WPFoundationTests", dependencies: ["WPFoundation"]),
    .target(
      name: "WPSilentModeSwitch",
      dependencies: [
        "WPFoundation",
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        .product(name: "Clocks", package: "swift-clocks")
      ],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "WPSilentModeSwitchTests",
      dependencies: [
        "WPSilentModeSwitch",
        .product(name: "Numerics", package: "swift-numerics")
      ]
    )
  ],
  swiftLanguageVersions: [.version("6")]
)

for target in package.targets {
  target.swiftSettings = target.swiftSettings ?? []
  target.swiftSettings?
    .append(
      .unsafeFlags([
        "-Xfrontend", "-warn-concurrency",
        "-Xfrontend", "-enable-actor-data-race-checks",
        "-emit-symbol-graph",
        "-enable-bare-slash-regex"
      ])
    )
}
