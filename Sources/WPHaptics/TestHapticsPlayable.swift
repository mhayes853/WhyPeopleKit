import os

/// A ``HapticsPlayable`` conformance that is suitable to use for test stubbing.
public final class TestHapticsPlayable<HapticEvent: Sendable>: HapticsPlayable, Sendable {
  private let _playedEvents = OSAllocatedUnfairLock(initialState: [HapticEvent]())
  
  public init() {}
  
  /// An array of the played events in the order they were played.
  public var playedEvents: [HapticEvent] {
    self._playedEvents.withLock { $0 }
  }
  
  public func play(event: HapticEvent) async throws {
    self._playedEvents.withLock { $0.append(event) }
  }
}
