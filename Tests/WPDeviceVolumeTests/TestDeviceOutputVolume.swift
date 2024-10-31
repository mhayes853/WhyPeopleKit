import ConcurrencyExtras
import Foundation
import WPDeviceVolume

final class TestDeviceOutputVolume: DeviceOutputVolume, Sendable {
  private struct State {
    var subscribers = [UUID: @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void]()
    var buffer = [Result<DeviceOutputVolumeStatus, any Error>]()
  }

  private let subscribers = LockIsolated(State())

  func subscribe(
    _ callback: @escaping @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    let id = UUID()
    self.subscribers.withValue {
      for result in $0.buffer {
        callback(result)
      }
      $0.subscribers[id] = callback
    }
    return DeviceOutputVolumeSubscription {
      _ = self.subscribers.withValue { $0.subscribers.removeValue(forKey: id) }
    }
  }

  func send(result: Result<DeviceOutputVolumeStatus, any Error>) async {
    self.subscribers.withValue {
      $0.buffer.append(result)
      for callback in $0.subscribers.values {
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
