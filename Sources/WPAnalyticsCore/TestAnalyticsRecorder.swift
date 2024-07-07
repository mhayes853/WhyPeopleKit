import Foundation
import os

// MARK: - TestAnalyticsRecorder

/// An ``AnalyticsRecordable`` that records events in-memory such that inspection is possible
/// during testing.
public final class TestAnalyticsRecorder: Sendable {
  private let events = OSAllocatedUnfairLock(initialState: [AnalyticsEvent]())
  
  public init() {}
}

// MARK: - Event Inspection

extension TestAnalyticsRecorder {
  /// All recorded events in the order that they were recorded in.
  public var recordedEvents: [AnalyticsEvent] {
    self.events.withLock { $0 }
  }
  
  /// Returns the count of how many times an event was recorded.
  ///
  /// - Parameter event: The ``AnalyticsEvent`` to count.
  /// - Returns: The number of times that `event` was recorded.
  public func count(of event: AnalyticsEvent) -> Int {
    self.recordedEvents.count { $0 == event }
  }
  
  /// Returns true if an instance of `event` was recorded.
  ///
  /// - Parameter event: The ``AnalyticsEvent`` to check.
  /// - Returns: True if an instance of `event` was recorded.
  public func didRecord(event: AnalyticsEvent) -> Bool {
    self.count(of: event) > 0
  }
}

// MARK: - AnalyticsRecordable Conformance

extension TestAnalyticsRecorder: AnalyticsRecordable {
  public func record(event: AnalyticsEvent) {
    self.events.withLock { $0.append(event) }
  }
}
