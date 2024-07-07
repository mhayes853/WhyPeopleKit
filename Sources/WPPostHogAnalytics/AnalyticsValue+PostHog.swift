import WPAnalyticsCore

// MARK: - PostHog Value

extension AnalyticsEvent.Value {
  /// This value as a PostHog compatible value.
  public var postHogValue: Any {
    switch self {
    case let .integer(i): i
    case let .unsignedInteger(u): u
    case let .string(s): s
    case let .boolean(b): b
    case let .double(d): d
    case let .date(d): d
    case let .url(u): u
    case let .array(a): a.map(\.?.postHogValue)
    case let .dict(d): d.mapValues(\.?.postHogValue)
    }
  }
}

// MARK: - PostHog Properties

public typealias PostHogProperties = [String: Any]

extension Dictionary where Key == String, Value == AnalyticsEvent.Value? {
  /// These properties as PostHog compatible properties.
  public var postHogProperties: PostHogProperties {
    self.mapValues(\.?.postHogValue)
  }
}

extension Dictionary where Key == String, Value == AnalyticsEvent.Value {
  /// These properties as PostHog compatible properties.
  public var postHogProperties: PostHogProperties {
    self.mapValues(\.postHogValue)
  }
}
