import Foundation

// MARK: - RandomGenerationSeed

/// A seed for pseudo-random-number generation.
public struct RandomGenerationSeed: Hashable, Sendable, Codable, RawRepresentable {
  public let rawValue: UInt64

  public init(rawValue: UInt64) {
    self.rawValue = rawValue
  }
}

// MARK: - Current

extension RandomGenerationSeed {
  /// Initializes a generation seed based on the current time in seconds.
  public init() {
    self.init(rawValue: splitmix64(UInt64(time(nil))))
  }
}

// MARK: - ExpressibleByIntegerLiteral

extension RandomGenerationSeed: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self.init(rawValue: UInt64(value))
  }
}

// MARK: - Zero

extension RandomGenerationSeed {
  public static let zero = Self(rawValue: 0)
}
