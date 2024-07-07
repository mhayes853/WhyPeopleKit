import WPFoundation

public struct FailingAnalyticsRecordable: AnalyticsRecordable, Sendable {
  public init() {}
  
  public func record(event: AnalyticsEvent) {
    failCurrentTest("FailingAnalyticsRecordable. Event: \(event).")
  }
}

// MARK: - Extension

extension AnalyticsRecordable where Self == FailingAnalyticsRecordable {
  public static var failing: Self {
    FailingAnalyticsRecordable()
  }
}
