import Testing
import WPDeviceVolume
import WPFoundation

@Suite("DeviceOutputVolumeSubscription tests")
struct DeviceOutputVolumeSubscriptionTests {
  @Test("Only Cancels Once")
  func cancelsOnce() {
    let count = Lock(0)
    let subscription = DeviceOutputVolumeSubscription { count.withLock { $0 += 1 } }
    subscription.cancel()
    count.withLock { #expect($0 == 1) }

    subscription.cancel()
    count.withLock { #expect($0 == 1) }
  }
}
