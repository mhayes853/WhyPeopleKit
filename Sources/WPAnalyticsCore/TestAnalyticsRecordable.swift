import Foundation
import os

public final class TestAnalyticsRecordable: AnalyticsRecordable, Sendable {
  private let events = OSAllocatedUnfairLock(initialState: [AnalyticsEvent]())
  
  public var recordedEvents: [AnalyticsEvent] {
    self.events.withLock { $0 }
  }
  
  public init() {}
  
  public func record(event: AnalyticsEvent) {
    self.events.withLock { $0.append(event) }
  }
}
