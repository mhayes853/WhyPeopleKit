import IssueReporting

// MARK: - IssueReportingAnalyticsRecorder

/// An ``AnalyticsRecordable`` conformance that reports an issue using swift-issue-reporting when
/// recording analytics events.
public struct IssueReportingAnalyticsRecorder: AnalyticsRecordable, Sendable {
  public init() {}

  public func record(event: AnalyticsEvent) {
    reportIssue("[Analytics]: \(event).")
  }
}

// MARK: - Extension

extension AnalyticsRecordable where Self == IssueReportingAnalyticsRecorder {
  /// An ``AnalyticsRecordable`` conformance that reports an issue using swift-issue-reporting when
  /// recording analytics events.
  public static var issueReporting: Self {
    IssueReportingAnalyticsRecorder()
  }
}
