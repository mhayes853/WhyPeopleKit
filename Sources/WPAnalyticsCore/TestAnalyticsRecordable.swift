import Foundation
import os

/// An ``AnalyticsRecordable`` that records events in-memory such that inspection is possible
/// during testing.
public final class TestAnalyticsRecordable: AnalyticsRecordable, Sendable {
  private let events = OSAllocatedUnfairLock(initialState: [AnalyticsEvent]())
  
  /// All recorded events in the order that they were recorded in.
  public var recordedEvents: [AnalyticsEvent] {
    self.events.withLock { $0 }
  }
  
  public init() {}
  
  public func record(event: AnalyticsEvent) {
    self.events.withLock { $0.append(event) }
  }
}
