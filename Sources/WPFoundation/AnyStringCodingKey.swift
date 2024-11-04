// MARK: - AnyStringCodingKey

/// A `CodingKey` that is always an arbitrary string.
public struct AnyStringCodingKey: CodingKey, Hashable, Sendable {
  public var stringValue: String

  public init(stringValue: String) {
    self.stringValue = stringValue
  }

  public var intValue: Int?

  public init?(intValue: Int) {
    return nil
  }
}

// MARK: - ExpressibleByStringLiteral

extension AnyStringCodingKey: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.stringValue = value
  }
}

// MARK: - ExprressibleByStringInterpolation

extension AnyStringCodingKey: ExpressibleByStringInterpolation {}
