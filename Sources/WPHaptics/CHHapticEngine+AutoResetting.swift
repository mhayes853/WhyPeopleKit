#if canImport(CoreHaptics)
  import CoreHaptics

  extension CHHapticEngine {
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
