import ConcurrencyExtras
import Dependencies
import WPHaptics

// MARK: - AHAP Player

extension DependencyValues {
  /// A dependency for a haptics player that plays `AHAPPattern`s.
  public var hapticsPlayer: AnyHapticsPlayable<AHAPPattern> {
    get { self[HapticsPlayerKey.self].value }
    set { self[HapticsPlayerKey.self].value = newValue }
  }

  private struct HapticsPlayerKey: TestDependencyKey {
    public static var testValue: UncheckedSendable<AnyHapticsPlayable<AHAPPattern>> {
      UncheckedSendable(AnyHapticsPlayable(TestHapticsPlayable<AHAPPattern>()))
    }
  }
}

// MARK: - WatchKit Player

#if os(watchOS)
  import WatchKit

  extension DependencyValues {
    /// A dependency for a haptics player that plays watch haptics.
    public var watchHapticsPlayer: AnyHapticsPlayable<WKHapticType> {
      get { self[WatchHapticsPlayerKey.self].value }
      set { self[WatchHapticsPlayerKey.self].value = newValue }
    }

    private struct WatchHapticsPlayerKey: DependencyKey {
      public static var liveValue: UncheckedSendable<AnyHapticsPlayable<WKHapticType>> {
        UncheckedSendable(AnyHapticsPlayable(WKInterfaceDevice.current()))
      }

      public static var testValue: UncheckedSendable<AnyHapticsPlayable<WKHapticType>> {
        UncheckedSendable(AnyHapticsPlayable(TestHapticsPlayable<WKHapticType>()))
      }
    }
  }
#endif
