/// A protocol for genericly playing haptic events.
public protocol HapticsPlayable<HapticEvent> {
  associatedtype HapticEvent

  /// Attempts to play the specified ``HapticEvent``.
  ///
  /// - Parameter event: The ``HapticEvent`` defined by this conformance.
  func play(event: HapticEvent) async throws
}
