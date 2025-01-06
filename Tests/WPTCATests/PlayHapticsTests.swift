//import CustomDump
//import Testing
//import WPDependencies
//import WPHaptics
//import WPTCA

//@MainActor
//@Suite("PlayHaptics tests")
//struct PlayHapticsTests {
//  @Test("Plays Haptics When Haptic Event Returned")
//  func playsHaptics() async {
//    let haptics = TestHapticsPlayable<AHAPPattern>()
//    let store = TestStore(initialState: TestReducer.State()) {
//      TestReducer()
//    } withDependencies: {
//      $0.hapticsPlayer = AnySendableHapticsPlayable(haptics)
//    }

//    await store.send(.toggled) {
//      $0.isToggled = true
//    }
//    expectNoDifference(haptics.playedEvents, [.eventsOnly])
//  }

//  @Test("Does Not Play Haptics When Nil Returned")
//  func doesNotPlayHaptics() async {
//    let haptics = TestHapticsPlayable<AHAPPattern>()
//    let store = TestStore(initialState: TestReducer.State(isToggled: true)) {
//      TestReducer()
//    } withDependencies: {
//      $0.hapticsPlayer = AnySendableHapticsPlayable(haptics)
//    }

//    await store.send(.toggled) {
//      $0.isToggled = false
//    }
//    expectNoDifference(haptics.playedEvents, [])
//  }
//}

//@Reducer
//private struct TestReducer {
//  @ObservableState
//  struct State: Equatable {
//    var isToggled = false
//  }

//  enum Action {
//    case toggled
//  }

//  var body: some ReducerOf<Self> {
//    Reduce<State, Action> { state, action in
//      switch action {
//      case .toggled:
//        state.isToggled.toggle()
//        return .none
//      }
//    }
//    PlayAHAPPattern<State, Action> { state, _ in
//      state.isToggled ? .eventsOnly : nil
//    }
//  }
//}

//extension AHAPPattern {
//  static let eventsOnly = Self(
//    .event(
//      .hapticContinuous(
//        time: 0,
//        duration: 2,
//        parameters: [.hapticIntensity: 0.5, .hapticSharpness: 0.67, .decayTime: 0.9]
//      )
//    ),
//    .event(
//      .hapticTransient(time: 0.1, parameters: [.hapticIntensity: 0.8, .hapticSharpness: 0.2])
//    ),
//    .event(
//      .audioCustom(
//        time: 0.5,
//        waveformPath: "bang.caf",
//        waveformLoopEnabled: true,
//        parameters: [.audioVolume: 0.5]
//      )
//    ),
//    .event(.audioContinuous(time: 2, duration: 2, parameters: [.audioPan: 0.8, .audioVolume: 0.3]))
//  )
//}
