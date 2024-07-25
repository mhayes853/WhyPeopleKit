import WPFoundation
private import IssueReporting

// MARK: - FailingAnalyticsRecorder

/// An ``AnalyticsRecordable`` conformance that fails the current test when an event is recorded.
public struct FailingAnalyticsRecorder: AnalyticsRecordable, Sendable {
  public init() {}
  
  public func record(event: AnalyticsEvent) {
    reportIssue("[Analytics]: \(event).")
  }
}

// MARK: - Extension

extension AnalyticsRecordable where Self == FailingAnalyticsRecorder {
  /// An ``AnalyticsRecordable`` conformance that fails the current test when an event is recorded.
  public static var failing: Self {
    FailingAnalyticsRecorder()
  }
}
