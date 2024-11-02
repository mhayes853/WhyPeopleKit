#if canImport(CoreHaptics)
  import CoreHaptics

  /// A `CHHapticEngine` subclass that's marked as Sendable.
  ///
  /// `CHHapticEngine` is thread-safe per Apple docs, but is not marked as Sendable due to the
  /// possibility of subclassing. Therefore, we can make a non-subclassable subclass of the engine
  /// and safely mark it as Sendable.
  public final class SendableCHHapticEngine: CHHapticEngine, @unchecked Sendable {}
#endif
