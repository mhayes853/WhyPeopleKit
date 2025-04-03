#if os(watchOS)
  import WatchKit

  public struct WKInterfaceDevicePlayer: HapticsPlayable, Sendable {
    public init() {}
    public func play(event: WKHapticType) {
      WKInterfaceDevice.current().play(event)
    }
  }
#endif
