#if canImport(ComposableArchitecture)
  import ComposableArchitecture
  import WPHaptics
  import WPDependencies

  // MARK: - PlayAHAPPattern

  @Reducer
  public struct PlayAHAPPattern<State: Sendable, Action: Sendable> {
    @Dependency(\.hapticsPlayer) private var player
    private let event: @Sendable (State, Action) -> AHAPPattern?

    public init(
      makeEvent event: @Sendable @escaping (State, Action) -> AHAPPattern?
    ) {
      self.event = event
    }

    public var body: some Reducer<State, Action> {
      PlayHaptics(player: self.player, makeEvent: self.event)
    }
  }

  // MARK: - PlayWatchHaptics

  #if os(watchOS)
    import WatchKit

    @Reducer
    public struct PlayWatchHaptics<State: Sendable, Action: Sendable> {
      @Dependency(\.watchHapticsPlayer) private var player
      private let event: @Sendable (State, Action) -> WKHapticType?

      public init(
        makeEvent event: @Sendable @escaping (State, Action) -> WKHapticType?
      ) {
        self.event = event
      }

      public var body: some Reducer<State, Action> {
        PlayHaptics(player: self.player, makeEvent: self.event)
      }
    }
  #endif

  // MARK: - PlayHaptics

  @Reducer
  public struct PlayHaptics<State: Sendable, Action: Sendable, HapticsEvent>: Sendable {
    private let player: AnySendableHapticsPlayable<HapticsEvent>
    private let event: @Sendable (State, Action) -> HapticsEvent?

    public init(
      player: AnySendableHapticsPlayable<HapticsEvent>,
      makeEvent event: @Sendable @escaping (State, Action) -> HapticsEvent?
    ) {
      self.player = player
      self.event = event
    }

    public var body: some Reducer<State, Action> {
      Reduce { state, action in
        .run { [state] _ in
          guard let event = self.event(state, action) else { return }
          try await self.player.play(event: event)
        }
      }
    }
  }

#endif
