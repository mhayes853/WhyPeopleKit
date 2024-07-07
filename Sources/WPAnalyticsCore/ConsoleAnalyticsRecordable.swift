// MARK: - ConsoleAnalyticsRecordable

/// An ``AnalyticsRecordable`` conformance that logs events to the console.
public struct ConsoleAnalyticsRecordable: AnalyticsRecordable, Sendable {
  public init() {}
  
  public func record(event: AnalyticsEvent) {
#if DEBUG
    print("[Analytics]: \(event).")
#endif
  }
}

// MARK: - Extension

extension AnalyticsRecordable where Self == ConsoleAnalyticsRecordable {
  /// An ``AnalyticsRecordable`` conformance that logs events to the console.
  public static var console: Self {
    ConsoleAnalyticsRecordable()
  }
}
