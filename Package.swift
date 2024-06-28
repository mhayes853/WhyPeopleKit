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
    .library(name: "WPFoundation", targets: ["WPFoundation"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.11.2"),
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.13.0"),
    .package(url: "https://github.com/MobileNativeFoundation/Kronos", from: "4.2.2")
  ],
  targets: [
    .target(name: "WPFoundation"),
    .testTarget(name: "WPFoundationTests", dependencies: ["WPFoundation"])
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
        "-enable-bare-slash-regex"
      ])
    )
}
