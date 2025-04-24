import WPFoundation

// MARK: - AnalyticsEvent

/// A type for a payload that can be recorded by an analytics platform.
///
/// This type contains a few cases which are deemed necessary for any analytics platform, and uses
/// the ``custom(_:)`` case when tapping into features specific to the analytics platform.
public enum AnalyticsEvent: Sendable {
  /// A typical analytics event with a name and associated properties.
  ///
  /// You can also initialize this case by using the ``init(_:properties:)`` and string literal
  /// initializers.
  ///
  /// - Parameters:
  ///   - name: The name of the event.
  ///   - properties: The properties associated with the event.
  case event(name: String, properties: [String: Value?])

  /// An event for identifying the current user.
  ///
  /// - Parameters:
  ///   - distinctId: A string that uniquely identifies the current user.
  case identify(distinctId: String)

  /// An event for opting in and out of analytics tracking.
  case opt(AnalyticsOptInStatus)

  /// An event for associating properties with the current user.
  case setUserProperties([String: Value?])

  /// An event for defining custom events.
  ///
  /// You can use this case to define events that tap into functionallity particular to a specific
  /// analytics platform, or you can use it to define generic events that are not represented by
  /// this type.
  ///
  /// Any event passed into this case must be both `Sendable` and `Equatable`. To avoid equality
  /// conflicts, you'll want to create a dedicated type for each kind of custom event in your
  /// application.
  ///
  /// ```swift
  /// struct TrackChargeEvent: Equatable, Sendable {
  ///   let amount: Double
  ///   let properties: [String: Value?]
  /// }
  ///
  /// extension AnalyticsEvent {
  ///   static func trackCharge(amount: Double, properties: [String: Value?]) -> Self {
  ///     .custom(TrackChargeEvent(amount: amount, properties: properties))
  ///   }
  /// }
  /// ```
  ///
  /// Then when implementing ``AnalyticsRecordable``, make sure to handle this type of event in
  /// ``AnalyticsRecordable/record(event:)``.
  ///
  /// ```swift
  /// struct MyAnalyticsRecorder: AnalyticsRecordable {
  ///   func record(event: AnalyticsEvent) {
  ///     switch event {
  ///       case let .event(name, properties):
  ///         // ...
  ///
  ///       case let .identify(distinctId):
  ///         // ...
  ///
  ///       case let .setUserProperties(properties):
  ///         // ...
  ///
  ///       case let .opt(status):
  ///         // ...
  ///
  ///       case let .custom(event):
  ///         guard let event = event as? TrackChargeEvent else { return }
  ///         // Record the event somehow...
  ///     }
  ///   }
  /// }
  /// ```
  case custom(any Equatable & Sendable)
}

// MARK: - Equatable

extension AnalyticsEvent: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.event(n1, p1), .event(n2, p2)):
      n1 == n2 && p1 == p2
    case let (.identify(id1), .identify(id2)):
      id1 == id2
    case let (.opt(s1), .opt(s2)):
      s1 == s2
    case let (.setUserProperties(p1), .setUserProperties(p2)):
      p1 == p2
    case let (.custom(c1), .custom(c2)):
      equals(c1, c2)
    default:
      false
    }
  }
}

// MARK: - Convenience Initializers

extension AnalyticsEvent {
  /// Initializes an ``AnalyticsEvent`` with the specified name and associated properties.
  ///
  /// - Parameters:
  ///   - name: The name of the event.
  ///   - properties: The properties associated with the event.
  public init(_ name: String, properties: [String: Value?] = [:]) {
    self = .event(name: name, properties: properties)
  }
}

extension AnalyticsEvent: ExpressibleByStringLiteral {
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
  @available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
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
  public init(dictionaryLiteral elements: (String, Self?)...) {
    self = .dict([String: Self?](uniqueKeysWithValues: elements))
  }
}

// MARK: - Value Codable

extension AnalyticsEvent.Value: Encodable {
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case let .string(value):
      try container.encode(value)
    case let .integer(value):
      try container.encode(value)
    case let .unsignedInteger(value):
      try container.encode(value)
    case let .url(value):
      try container.encode(value)
    case let .date(value):
      try container.encode(value)
    case let .double(value):
      try container.encode(value)
    case let .boolean(value):
      try container.encode(value)
    case let .array(value):
      try container.encode(value)
    case let .dict(value):
      try container.encode(value)
    }
  }
}

extension AnalyticsEvent.Value: Decodable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let string = try? container.decode(String.self) {
      self = .string(string)
    } else if let integer = try? container.decode(Int.self) {
      self = .integer(integer)
    } else if let unsignedInteger = try? container.decode(UInt.self) {
      self = .unsignedInteger(unsignedInteger)
    } else if let double = try? container.decode(Double.self) {
      self = .double(double)
    } else if let boolean = try? container.decode(Bool.self) {
      self = .boolean(boolean)
    } else if let array = try? container.decode([Self].self) {
      self = .array(array)
    } else if let dict = try? container.decode([String: Self?].self) {
      self = .dict(dict)
    } else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value")
    }
  }
}
