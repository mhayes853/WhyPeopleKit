#if canImport(CoreHaptics)
import CoreHaptics

// MARK: - CHHapticPatternConvertible

/// A protocol for creating `CHHapticPattern`.
public protocol CHHapticPatternConvertible {
  /// Attempts to create a `CHHapticPattern`.
  func hapticPattern() throws -> CHHapticPattern
}

// MARK: - CHHapticPattern Conformance

extension CHHapticPattern: CHHapticPatternConvertible {
  public func hapticPattern() -> CHHapticPattern {
    self
  }
}

// MARK: - CHHapticEngine Conformance

extension CHHapticEngine: HapticsPlayable {
  public func play(event: any CHHapticPatternConvertible) async throws {
    try await self.start()
    let player = try self.makePlayer(with: event.hapticPattern())
    try player.start(atTime: CHHapticTimeImmediate)
  }
}
#endif
