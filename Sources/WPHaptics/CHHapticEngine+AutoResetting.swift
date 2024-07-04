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
    engine.resetHandler = { [weak engine] in try? engine?.start() }
    return engine
  }
}
#endif
