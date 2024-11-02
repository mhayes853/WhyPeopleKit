#if os(watchOS)
  import WatchKit

  extension WKInterfaceDevice: HapticsPlayable {
    public typealias HapticEvent = WKHapticType

    public func play(event: WKHapticType) {
      self.play(event)
    }
  }
#endif
