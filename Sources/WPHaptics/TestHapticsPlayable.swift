import Foundation

/// A ``HapticsPlayable`` conformance that is suitable to use for test stubbing.
public final class TestHapticsPlayable<HapticEvent>: HapticsPlayable, @unchecked Sendable {
  private let lock = NSLock()
  private var _playedEvents = [HapticEvent]()
  
  public init() {}
  
  /// An array of the played events in the order they were played.
  public var playedEvents: [HapticEvent] {
    self.lock.withLock { self._playedEvents }
  }
  
  public func play(event: HapticEvent) {
    self.lock.withLock { self._playedEvents.append(event) }
  }
}
