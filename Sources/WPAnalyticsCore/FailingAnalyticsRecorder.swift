import WPFoundation

// MARK: - FailingAnalyticsRecorder

/// An ``AnalyticsRecordable`` conformance that fails the current test when an event is recorded.
public struct FailingAnalyticsRecorder: AnalyticsRecordable, Sendable {
  public init() {}
  
  public func record(event: AnalyticsEvent) {
    failCurrentTest("[Analytics]: \(event).")
  }
}

// MARK: - Extension

extension AnalyticsRecordable where Self == FailingAnalyticsRecorder {
  /// An ``AnalyticsRecordable`` conformance that fails the current test when an event is recorded.
  public static var failing: Self {
    FailingAnalyticsRecorder()
  }
}
