import Foundation

/// A protocol for recording analytics events.
public protocol AnalyticsRecordable {
  /// Records the specifed ``AnalyticsEvent``.
  ///
  /// - Parameter event: The ``AnalyticsEvent`` to record.
  func record(event: AnalyticsEvent)
}
