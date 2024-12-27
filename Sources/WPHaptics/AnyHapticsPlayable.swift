/// A type-erased ``HapticsPlayable`` that is also sendable.
public struct AnySendableHapticsPlayable<HapticEvent>: HapticsPlayable, Sendable {
  private let play: @Sendable (HapticEvent) async throws -> Void

  /// Type-erases a haptics player.
  ///
  /// - Parameter player: A haptics player.
  public init(_ player: some HapticsPlayable<HapticEvent> & Sendable) {
    self.play = { @Sendable in try await player.play(event: $0) }
  }

  public func play(event: HapticEvent) async throws {
    try await self.play(event)
  }
}
