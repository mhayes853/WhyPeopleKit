import WPFoundation

// MARK: - FailingAnalyticsRecordable

/// An ``AnalyticsRecordable`` conformance that fails the current test when an event is recorded.
public struct FailingAnalyticsRecordable: AnalyticsRecordable, Sendable {
  public init() {}
  
  public func record(event: AnalyticsEvent) {
    failCurrentTest("[Analytics]: \(event).")
  }
}

// MARK: - Extension

extension AnalyticsRecordable where Self == FailingAnalyticsRecordable {
  /// An ``AnalyticsRecordable`` conformance that fails the current test when an event is recorded.
  public static var failing: Self {
    FailingAnalyticsRecordable()
  }
}
