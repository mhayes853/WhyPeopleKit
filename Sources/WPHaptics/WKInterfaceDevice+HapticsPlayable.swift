#if os(watchOS)
  import WatchKit

  extension WKInterfaceDevice: HapticsPlayable {
    public typealias HapticEvent = WKHapticType

    public func play(event: WKHapticType) {
      self.play(event)
    }
  }

  public struct WKInterfaceDevicePlayer: HapticsPlayable, Sendable {
    public init() {}
    public func play(event: WKHapticType) {
      WKInterfaceDevice.current.play(event)
    }
  }
#endif
