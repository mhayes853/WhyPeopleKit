/// A type-erased ``HapticsPlayable``.
public struct AnyHapticsPlayable<HapticEvent>: HapticsPlayable {
  private let play: (HapticEvent) async throws -> Void

  /// Type-erases a haptics player.
  ///
  /// - Parameter player: A haptics player.
  public init(_ player: any HapticsPlayable<HapticEvent>) {
    self.play = { try await player.play(event: $0) }
  }

  public func play(event: HapticEvent) async throws {
    try await self.play(event)
  }
}
