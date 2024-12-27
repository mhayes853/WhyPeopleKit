// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WhyPeopleKit",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
    .macCatalyst(.v13)
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
    .library(name: "WPSnapshotTesting", targets: ["WPSnapshotTesting"]),
    .library(name: "WPJavascriptCore", targets: ["WPJavascriptCore"]),
    .library(name: "WPSharing", targets: ["WPSharing"]),
    .library(name: "WPTCA", targets: ["WPTCA"])
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
    .package(url: "https://github.com/apple/swift-log", from: "1.6.1"),
    .package(url: "https://github.com/pointfreeco/swift-sharing", from: "1.1.1"),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      .upToNextMajor(from: "1.17.0")
    )
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
        .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay"),
        .product(name: "Logging", package: "swift-log")
      ]
    ),
    .target(
      name: "WPDeviceVolume",
      dependencies: [
        "WPFoundation",
        "WPSwiftNavigation",
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
    .target(name: "WPHaptics", dependencies: ["WPFoundation"]),
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
        .product(name: "Mixpanel", package: "mixpanel-swift", condition: .whenApplePlatforms)
      ]
    ),
    .testTarget(name: "WPMixpanelAnalyticsTests", dependencies: ["WPMixpanelAnalytics"]),
    .target(
      name: "WPPostHogAnalytics",
      dependencies: [
        "WPAnalyticsCore",
        .product(name: "PostHog", package: "posthog-ios", condition: .whenApplePlatforms)
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
        .product(name: "GRDB", package: "GRDB.swift", condition: .whenApplePlatforms),
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "Logging", package: "swift-log")
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
    ),
    .target(
      name: "WPJavascriptCore",
      dependencies: [
        "WPFoundation",
        "_CWPJavascriptCore",
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "CustomDump", package: "swift-custom-dump")
      ],
      resources: [.process("js")]
    ),
    .testTarget(
      name: "WPJavascriptCoreTests",
      dependencies: [
        "WPJavascriptCore", "WPSnapshotTesting", .product(name: "Clocks", package: "swift-clocks")
      ]
    ),
    .target(name: "_CWPJavascriptCore"),
    .target(
      name: "WPSharing",
      dependencies: [
        "WPDeviceVolume",
        "WPDependencies",
        .product(name: "Sharing", package: "swift-sharing")
      ]
    ),
    .testTarget(
      name: "WPSharingTests",
      dependencies: ["WPSharing", .product(name: "CustomDump", package: "swift-custom-dump")]
    ),
    .target(
      name: "WPTCA",
      dependencies: [
        "WPSwiftNavigation",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    )
  ],
  swiftLanguageModes: [.version("6")]
)

extension TargetDependencyCondition {
  static var whenApplePlatforms: Self? {
    .when(platforms: [.iOS, .macOS, .watchOS, .tvOS, .visionOS])
  }
}
