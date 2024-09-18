// MARK: - ConsoleAnalyticsRecorder

/// An ``AnalyticsRecordable`` conformance that logs events to the console.
public struct ConsoleAnalyticsRecorder: AnalyticsRecordable, Sendable {
  public init() {}

  public func record(event: AnalyticsEvent) {
    #if DEBUG
      print("[Analytics]: \(event).")
    #endif
  }
}

// MARK: - Extension

extension AnalyticsRecordable where Self == ConsoleAnalyticsRecorder {
  /// An ``AnalyticsRecordable`` conformance that logs events to the console.
  public static var console: Self {
    ConsoleAnalyticsRecorder()
  }
}

// MARK: - Console Logging with Another Recordable

extension AnalyticsRecordable {
  /// Adds console logging to each event recorded by this recordable.
  public func withConsoleLogging() -> _WithConsoleLoggingRecordable<Self> {
    _WithConsoleLoggingRecordable(base: self)
  }
}

public struct _WithConsoleLoggingRecordable<Base: AnalyticsRecordable>: AnalyticsRecordable {
  let base: Base
  let console = ConsoleAnalyticsRecorder()

  public func record(event: AnalyticsEvent) {
    self.base.record(event: event)
    self.console.record(event: event)
  }
}
