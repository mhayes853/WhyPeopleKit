import WPAnalyticsCore

extension DependencyValues {
  public var analyticsRecordable: any AnalyticsRecordable & Sendable {
    get { self[AnalyticsRecordableKey.self] }
    set { self[AnalyticsRecordableKey.self] = newValue }
  }
  
  private struct AnalyticsRecordableKey: TestDependencyKey {
    static var testValue: any AnalyticsRecordable & Sendable {
      FailingAnalyticsRecordable()
    }
  }
}
