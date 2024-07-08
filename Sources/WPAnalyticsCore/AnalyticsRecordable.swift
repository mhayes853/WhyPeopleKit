import Foundation

/// A protocol for recording analytics events.
public protocol AnalyticsRecordable {
  /// Records the specifed ``AnalyticsEvent``.
  ///
  /// - Parameter event: The ``AnalyticsEvent`` to record.
  func record(event: AnalyticsEvent)
}

extension AnalyticsRecordable {
  /// Records an analytics event with the spcified name and associated properties.
  ///
  /// - Parameters:
  ///   - name: The name of the event.
  ///   - properties: The properties associated with the event.
  public func record(name: String, properties: [String: AnalyticsEvent.Value?] = [:]) {
    self.record(event: AnalyticsEvent(name, properties: properties))
  }
}
