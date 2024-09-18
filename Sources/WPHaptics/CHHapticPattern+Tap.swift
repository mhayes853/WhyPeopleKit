#if canImport(CoreHaptics)
  import CoreHaptics

  // MARK: - Tap

  extension CHHapticPattern {
    /// Attempts to initialize a pattern that is useful for tap events.
    ///
    /// This pattern plays a singular transient event that starts imediately. The intensity and
    /// sharpness of the event can be customized. For actions invoked by less significant UI
    /// elements, it's better to use a ligher intensity and sharpness than actions invoked by higher
    /// priority UI elements.
    ///
    /// - Parameters:
    ///   - intensity: The intensity of the single event in the pattern in the range [0, 1].
    ///   - sharpness: The sharpness of the single event in the pattern in the range [0, 1].
    /// - Returns: A `CHHapticPattern` that plays a single transient event.
    public static func tap(intensity: Float, sharpness: Float) throws -> CHHapticPattern {
      try CHHapticPattern(
        events: [
          CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
              CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: sharpness
              ),
              CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: intensity
              )
            ],
            relativeTime: CHHapticTimeImmediate
          )
        ],
        parameters: []
      )
    }

    /// Attempts to initialize a pattern that is useful for responding to tap events on high
    /// priority UI elements.
    public static func strongTap() throws -> CHHapticPattern {
      try Self.tap(intensity: 0.75, sharpness: 0.75)
    }

    /// Attempts to initialize a pattern that is useful for responding to tap events on medium
    /// priority UI elements.
    public static func simpleTap() throws -> CHHapticPattern {
      try Self.tap(intensity: 0.5, sharpness: 0.5)
    }
  }

#endif
