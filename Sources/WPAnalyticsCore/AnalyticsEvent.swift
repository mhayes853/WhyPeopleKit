import Foundation

// MARK: - AnalyticsEvent

public enum AnalyticsEvent: Sendable {
  case event(name: String, properties: [String: Value?])
  case identify(distinctId: String)
  case opt(OptInStatus)
  case setUserProperties([String: Value?])
  case custom(any Sendable)
}

// MARK: - Convenience Initializers

extension AnalyticsEvent {
  /// Initializes an ``AnalyticsEvent`` with the specified name and associated properties.
  ///
  /// - Parameters:
  ///   - name: The name of the event.
  ///   - properties: The properties associated with the event.
  @inlinable
  public init(_ name: String, properties: [String: Value?] = [:]) {
    self = .event(name: name, properties: properties)
  }
}

extension AnalyticsEvent: ExpressibleByStringLiteral {
  @inlinable
  public init(stringLiteral value: StringLiteralType) {
    self.init(value)
  }
}

// MARK: - Value

extension AnalyticsEvent {
  /// A value that is represented in an analytics event.
  public enum Value: Hashable, Sendable {
    case integer(Int64)
    case unsignedInteger(UInt64)
    case string(String)
    case boolean(Bool)
    case double(Double)
    case date(Date)
    case url(URL)
    case array([Value?])
    case dict([String: Value?])
  }
}

// MARK: - Integer Values

extension AnalyticsEvent.Value {
  @inlinable
  public static func integer(_ i: Int) -> Self {
    .integer(Int64(i))
  }
  
  @inlinable
  public static func unsignedInteger(_ i: UInt) -> Self {
    .unsignedInteger(UInt64(i))
  }
  
  @inlinable
  public static func integer(_ i: Int16) -> Self {
    .integer(Int64(i))
  }
  
  @inlinable
  public static func unsignedInteger(_ i: UInt16) -> Self {
    .unsignedInteger(UInt64(i))
  }
  
  @inlinable
  public static func integer(_ i: Int8) -> Self {
    .integer(Int64(i))
  }
  
  @inlinable
  public static func unsignedInteger(_ i: UInt8) -> Self {
    .unsignedInteger(UInt64(i))
  }
}

// MARK: - Float Values

extension AnalyticsEvent.Value {
  @inlinable
  public static func float(_ f: Float16) -> Self {
    .double(Double(f))
  }
  
  @inlinable
  public static func float(_ f: Float) -> Self {
    .double(Double(f))
  }
}

// MARK: - Value Expressibles

extension AnalyticsEvent.Value: ExpressibleByStringLiteral {
  @inlinable
  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }
}

extension AnalyticsEvent.Value: ExpressibleByIntegerLiteral {
  @inlinable
  public init(integerLiteral value: IntegerLiteralType) {
    self = .integer(Int64(value))
  }
}

extension AnalyticsEvent.Value: ExpressibleByFloatLiteral {
  @inlinable
  public init(floatLiteral value: FloatLiteralType) {
    self = .double(Double(value))
  }
}

extension AnalyticsEvent.Value: ExpressibleByBooleanLiteral {
  @inlinable
  public init(booleanLiteral value: BooleanLiteralType) {
    self = .boolean(value)
  }
}

extension AnalyticsEvent.Value: ExpressibleByArrayLiteral {
  @inlinable
  public init(arrayLiteral elements: Self...) {
    self = .array(elements)
  }
}

extension AnalyticsEvent.Value: ExpressibleByDictionaryLiteral {
  @inlinable
  public init(dictionaryLiteral elements: (String, Self)...) {
    self = .dict([String: Self](uniqueKeysWithValues: elements))
  }
}