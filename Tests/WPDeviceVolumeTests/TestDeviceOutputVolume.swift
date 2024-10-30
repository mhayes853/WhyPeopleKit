import ConcurrencyExtras
import Foundation
import WPDeviceVolume

final class TestDeviceOutputVolume: DeviceOutputVolume, Sendable {
  private let subscribers = LockIsolated(
    [UUID: @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void]()
  )

  func subscribe(
    _ callback: @escaping @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    let id = UUID()
    self.subscribers.withValue { $0[id] = callback }
    return DeviceOutputVolumeSubscription {
      _ = self.subscribers.withValue { $0.removeValue(forKey: id) }
    }
  }

  func send(result: Result<DeviceOutputVolumeStatus, any Error>) async {
    self.subscribers.withValue {
      for callback in $0.values {
        callback(result)
      }
    }
    await Task.megaYield()
  }
}

struct NoopDeviceOutputVolume: DeviceOutputVolume {
  func subscribe(
    _ callback: @escaping @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    DeviceOutputVolumeSubscription {}
  }
}
