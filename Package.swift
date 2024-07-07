// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WhyPeopleKit",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v16),
    .watchOS(.v9),
    .macCatalyst(.v16)
  ],
  products: [
    .library(name: "WPFoundation", targets: ["WPFoundation"]),
    .library(name: "WPDeviceVolume", targets: ["WPDeviceVolume"]),
    .library(name: "WPTestSupport", targets: ["WPTestSupport"]),
    .library(name: "WPHaptics", targets: ["WPHaptics"]),
    .library(name: "WPDependencies", targets: ["WPDependencies"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.11.2"),
    .package(url: "https://github.com/pointfreeco/swift-clocks", from: "1.0.2"),
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.13.0"),
    .package(url: "https://github.com/MobileNativeFoundation/Kronos", from: "4.2.2"),
    .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.2"),
    .package(url: "https://github.com/pointfreeco/swift-perception", from: "1.2.4"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.3.1")
  ],
  targets: [
    .target(name: "WPFoundation", resources: [.process("Resources")]),
    .testTarget(
      name: "WPFoundationTests",
      dependencies: ["WPFoundation", "WPTestSupport"]
    ),
    .target(
      name: "WPDeviceVolume",
      dependencies: [
        "WPFoundation",
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        .product(name: "Perception", package: "swift-perception")
      ],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "WPDeviceVolumeTests",
      dependencies: [
        "WPDeviceVolume",
        .product(name: "Clocks", package: "swift-clocks"),
        .product(name: "Numerics", package: "swift-numerics")
      ]
    ),
    .target(name: "WPTestSupport", dependencies: ["WPFoundation"]),
    .testTarget(name: "WPTestSupportTests", dependencies: ["WPTestSupport"]),
    .target(name: "WPHaptics"),
    .target(
      name: "WPDependencies",
      dependencies: [
        "WPDeviceVolume",
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    .target(name: "WPAnalyticsCore")
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
