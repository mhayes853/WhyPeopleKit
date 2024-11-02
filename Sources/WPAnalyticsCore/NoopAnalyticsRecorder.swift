/// An ``AnalyticsRecordable`` type that does nothing when recording events.
public struct NoopAnalyticsRecorder: AnalyticsRecordable {
  @inlinable
  public init() {}

  @inlinable
  public func record(event: AnalyticsEvent) {
  }
}

extension AnalyticsRecordable where Self == NoopAnalyticsRecorder {
  /// An ``AnalyticsRecordable`` type that does nothing when recording events.
  public static var noop: Self {
    NoopAnalyticsRecorder()
  }
}
