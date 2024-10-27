#if canImport(CoreHaptics)
  import CoreHaptics

  extension CHHapticEngine {
    /// Attempts to create a `CHHapticEngine` instance with autoshutdown enabled, and with a reset
    /// handler that restarts the engine.
    ///
    /// - Returns: A `CHHapticEngine`.
    public static func autoResetting() throws -> CHHapticEngine {
      let engine = try CHHapticEngine()
      engine.isAutoShutdownEnabled = true
      engine.enableAutomaticRestarts()
      return engine
    }

    /// Enables automatic restarting when this engine resets.
    ///
    /// This method overrides the `resetHandler`, so ensure that you do not set `resetHandler`
    /// on this engine in a way that doesn't call the previous reset handler.
    public func enableAutomaticRestarts() {
      let handler = self.resetHandler
      self.resetHandler = { [weak self] in
        try? self?.start()
        handler()
      }
    }
  }
#endif
