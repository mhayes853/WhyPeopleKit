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
    .library(name: "WPDependencies", targets: ["WPDependencies"]),
    .library(name: "WPAnalyticsCore", targets: ["WPAnalyticsCore"]),
    .library(name: "WPMixpanelAnalytics", targets: ["WPMixpanelAnalytics"]),
    .library(name: "WPPostHogAnalytics", targets: ["WPPostHogAnalytics"]),
    .library(name: "WPSwiftNavigation", targets: ["WPSwiftNavigation"]),
    .library(name: "WPGRDB", targets: ["WPGRDB"]),
    .library(name: "WPPerception", targets: ["WPPerception"]),
    .library(name: "WPSnapshotTesting", targets: ["WPSnapshotTesting"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-clocks", .upToNextMajor(from: "1.0.4")),
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.2"),
    .package(url: "https://github.com/pointfreeco/swift-perception", .upToNextMajor(from: "1.0.0")),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies",
      .upToNextMajor(from: "1.3.9")
    ),
    .package(url: "https://github.com/mixpanel/mixpanel-swift", .upToNextMajor(from: "4.2.1")),
    .package(url: "https://github.com/PostHog/posthog-ios", .upToNextMajor(from: "3.0.0")),
    .package(
      url: "https://github.com/pointfreeco/xctest-dynamic-overlay",
      .upToNextMajor(from: "1.2.2")
    ),
    .package(url: "https://github.com/pointfreeco/swift-navigation", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/groue/GRDB.swift", .upToNextMajor(from: "6.0.0")),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.6"),
    .package(url: "https://github.com/apple/swift-log", from: "1.6.1")
  ],
  targets: [
    .target(
      name: "WPFoundation",
      dependencies: [.product(name: "IssueReporting", package: "xctest-dynamic-overlay")],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "WPFoundationTests",
      dependencies: [
        "WPFoundation",
        "WPTestSupport",
        .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay")
      ]
    ),
    .target(
      name: "WPDeviceVolume",
      dependencies: [
        "WPFoundation",
        .targetItem(name: "_WPDeviceVolumeMuteSound", condition: .when(platforms: [.iOS])),
        .product(name: "Perception", package: "swift-perception")
      ]
    ),
    .target(
      name: "_WPDeviceVolumeMuteSound",
      dependencies: ["WPFoundation"],
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
    .target(
      name: "WPTestSupport",
      dependencies: [
        "WPFoundation",
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay")
      ]
    ),
    .testTarget(name: "WPTestSupportTests", dependencies: ["WPTestSupport"]),
    .target(name: "WPHaptics"),
    .testTarget(
      name: "WPHapticsTests",
      dependencies: [
        "WPHaptics",
        "WPSnapshotTesting",
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing")
      ]
    ),
    .target(
      name: "WPDependencies",
      dependencies: [
        "WPDeviceVolume",
        "WPAnalyticsCore",
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    .target(
      name: "WPAnalyticsCore",
      dependencies: [
        "WPFoundation",
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "Logging", package: "swift-log")
      ]
    ),
    .testTarget(name: "WPAnalyticsCoreTests", dependencies: ["WPAnalyticsCore"]),
    .target(
      name: "WPMixpanelAnalytics",
      dependencies: [
        "WPAnalyticsCore",
        .product(name: "Mixpanel", package: "mixpanel-swift")
      ]
    ),
    .testTarget(name: "WPMixpanelAnalyticsTests", dependencies: ["WPMixpanelAnalytics"]),
    .target(
      name: "WPPostHogAnalytics",
      dependencies: [
        "WPAnalyticsCore",
        .product(name: "PostHog", package: "posthog-ios")
      ]
    ),
    .target(
      name: "WPSwiftNavigation",
      dependencies: [
        "WPFoundation",
        .product(name: "SwiftUINavigation", package: "swift-navigation"),
        .product(name: "UIKitNavigation", package: "swift-navigation")
      ]
    ),
    .testTarget(name: "WPSwiftNavigationTests", dependencies: ["WPSwiftNavigation"]),
    .target(
      name: "WPGRDB",
      dependencies: [
        "WPFoundation",
        .product(name: "GRDB", package: "GRDB.swift"),
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay")
      ]
    ),
    .testTarget(name: "WPGRDBTests", dependencies: ["WPGRDB"]),
    .target(
      name: "WPPerception",
      dependencies: [.product(name: "Perception", package: "swift-perception")]
    ),
    .testTarget(name: "WPPerceptionTests", dependencies: ["WPPerception"]),
    .target(
      name: "WPSnapshotTesting",
      dependencies: [
        "WPHaptics",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
      ]
    )
  ]
  //  swiftLanguageModes: [.version("6")]
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
