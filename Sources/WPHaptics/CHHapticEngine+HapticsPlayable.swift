#if canImport(CoreHaptics)
import CoreHaptics

extension CHHapticEngine: HapticsPlayable {
  public func play(event: CHHapticPattern) async throws {
    try await self.start()
    let player = try self.makePlayer(with: event)
    try player.start(atTime: CHHapticTimeImmediate)
  }
}
#endif
