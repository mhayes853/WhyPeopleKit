import Foundation

// MARK: - AnalyticsEventRecordable

public protocol AnalyticsRecordable {
  func record(event: AnalyticsEvent)
}

extension AnalyticsRecordable {
  @inlinable
  public func record(name: String, properties: [String: AnalyticsEvent.Value?] = [:]) {
    self.record(event: AnalyticsEvent(name, properties: properties))
  }
}
