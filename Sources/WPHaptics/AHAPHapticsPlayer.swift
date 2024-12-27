#if canImport(CoreHaptics)
  import CoreHaptics

  /// A ``HapticsPlayable`` that plays ``AHAPPattern``s.
  public struct AHAPHapticsPlayer: HapticsPlayable, Sendable {
    private let engine: SendableCHHapticEngine

    /// Creates an AHAP Pattern player from the specified engine.
    ///
    /// - Parameter engine: A ``SendableCHHapticEngine``.
    public init(engine: SendableCHHapticEngine) {
      self.engine = engine
    }

    public func play(event: AHAPPattern) async throws {
      try self.engine.playPattern(from: event.data())
    }
  }
#endif
