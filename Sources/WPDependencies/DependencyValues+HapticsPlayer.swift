import ConcurrencyExtras
import Dependencies
import WPHaptics

// MARK: - AHAP Player

extension DependencyValues {
  /// A dependency for a haptics player that plays `AHAPPattern`s.
  public var hapticsPlayer: AnySendableHapticsPlayable<AHAPPattern> {
    get { self[HapticsPlayerKey.self] }
    set { self[HapticsPlayerKey.self] = newValue }
  }

  private struct HapticsPlayerKey: TestDependencyKey {
    public static var testValue: AnySendableHapticsPlayable<AHAPPattern> {
      AnySendableHapticsPlayable(TestHapticsPlayable<AHAPPattern>())
    }
  }
}

// MARK: - WatchKit Player

#if os(watchOS)
  import WatchKit

  extension DependencyValues {
    /// A dependency for a haptics player that plays watch haptics.
    public var watchHapticsPlayer: AnySendableHapticsPlayable<WKHapticType> {
      get { self[WatchHapticsPlayerKey.self] }
      set { self[WatchHapticsPlayerKey.self] = newValue }
    }

    private struct WatchHapticsPlayerKey: DependencyKey {
      public static var liveValue: AnySendableHapticsPlayable<WKHapticType> {
        AnyHapticsPlayable(WKInterfaceDevicePlayer())
      }

      public static var testValue: AnySendableHapticsPlayable<WKHapticType> {
        AnyHapticsPlayable(TestHapticsPlayable<WKHapticType>())
      }
    }
  }
#endif
