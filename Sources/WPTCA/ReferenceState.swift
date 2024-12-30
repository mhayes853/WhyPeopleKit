import ComposableArchitecture
import WPFoundation

// MARK: - ReferenceState

/// A state data type that bases equality on reference equality.
///
/// Use this property wrapper if you want to hold a non-equatable value in a reducer's state. For
/// instance say a feature wants to interact with this audio player class.
/// ```swift
/// final class AudioPlayer: Sendable {
///   init(contentsOf url: URL) {
///     // ...
///   }
///
///   func play() {
///     // ...
///   }
///
///   func pause() {
///     // ...
///   }
/// }
/// ```
///
/// The feature will want to be able to reference the same audio player instance in multiple
/// reducer actions, such that it can pause and resume the audio. However, `AudioPlayer` is not
/// equatable, so we cannot hold it in the reducer's state and expect to use `TestStore` at the
/// same time. We may get around this issue by introducing a dependency that holds onto the audio
/// players, and then we can use that dependency in a reducer.
/// ```swift
/// @DependencyClient
/// struct AudioPlayersClient {
///   var play: @Sendable (URL) -> Void
///   var pause: @Sendable (URL) -> Void
///
///   static var liveValue: Self {
///     let players = Mutex([URL: AudioPlayer]())
///     return Self(
///       play: { url in /* ... */ },
///       pause: { url in /* ... */ }
///     )
///   }
/// }
///
/// @Reducer
/// struct AudioFeature: Sendable {
///   @ObservableState
///   struct State: Equatable, Sendable {
///     let url: URL
///   }
///
///   enum Action {
///     case played
///     case paused
///   }
///
///   @Dependency(AudioPlayersClient.self) private var players
///
///   var body: some ReducerOf<Self> {
///     Reduce { state, action in
///       switch action {
///       case .played: return .run { [state] _ in self.players.play(state.url) }
///       case .paused: return .run { [state] _ in self.players.pause(state.url) }
///       }
///     }
///   }
/// }
/// ```
///
/// However, this is cumbersome, and less efficient since it requires that we go through a lock to
/// access the the individual audio player instances. It would be more ideal to hold an
/// `AudioPlayer` instance in the reducer's state, as the player is localized to the feature's URL.
/// This can be done using the `@ReferenceState` property wrapper.
/// ```swift
/// @Reducer
/// struct AudioFeature: Sendable {
///   @ObservableState
///   struct State: Equatable, Sendable {
///     @ObservationStateIgnored
///     @ReferenceState var player: AudioPlayer
///
///     init(url: URL) {
///       self.player = AudioPlayer(contentsOf: url)
///     }
///   }
///
///   enum Action {
///     case played
///     case paused
///   }
///
///   var body: some ReducerOf<Self> {
///     Reduce { state, action in
///       switch action {
///       case .played: return .run { [state] _ in state.player.play() }
///       case .paused: return .run { [state] _ in state.player.pause() }
///       }
///     }
///   }
/// }
/// ```
/// This removes the need for the dependeny whilst keeping the state Equatable, allowing you to
/// safely use `AudioFeature` with a `TestStore` for testing.
///
/// The reference state value is Equatable based on the object identity of an internal reference
/// held by the property wrapper. Whenever a new value is assigned to the property wrapper, a new
/// reference is created, thus causing the 2 references to no longer be equal.
@propertyWrapper
@ObservableState
public struct ReferenceState<Value>: Equatable {
  private var storage: Storage
  public var wrappedValue: Value {
    get { self.storage.value }
    set { self.storage.value = newValue }
  }

  public init(wrappedValue: Value) {
    self.storage = Storage(wrappedValue)
  }
}

// MARK: - Sendable

extension ReferenceState: Sendable where Value: Sendable {}

// MARK: - Box

extension ReferenceState {
  // NB: Reference State is only sendable when Value is, so it's ok to make this inner class
  // unchecked sendable for convenience.
  private enum Storage: Equatable, @unchecked Sendable {
    case object(Value)
    case box(Box)

    init(_ value: Value) {
      if type(of: value) is AnyClass {
        self = .object(value)
      } else {
        self = .box(Box(value: value))
      }
    }

    var value: Value {
      get {
        switch self {
        case let .object(v): v
        case let .box(b): b.value
        }
      }
      set { self = Self(newValue) }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case let (.object(l), .object(r)):
        l as AnyObject === r as AnyObject
      case let (.box(l), .box(r)):
        l === r
      default:
        false
      }
    }
  }

  // NB: Reference State is only sendable when Value is, so it's ok to make this inner class
  // unchecked sendable for convenience.
  private final class Box: EquatableObject, @unchecked Sendable {
    let value: Value

    init(value: Value) {
      self.value = value
    }
  }
}
