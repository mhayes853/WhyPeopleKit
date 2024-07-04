#if canImport(CoreHaptics)
import CoreHaptics

// MARK: - CHHapticPatternConvertible

/// A protocol for creating `CHHapticPattern`.
public protocol CHHapticPatternConvertible {
  func hapticPattern() throws -> CHHapticPattern
}

// MARK: - CHHapticEngine Conformance

extension CHHapticEngine: HapticsPlayable {
  public func play(
    event: any CHHapticPatternConvertible
  ) async throws {
    try await self.start()
    let player = try self.makePlayer(with: event.hapticPattern())
    try player.start(atTime: CHHapticTimeImmediate)
  }
}
#endif
