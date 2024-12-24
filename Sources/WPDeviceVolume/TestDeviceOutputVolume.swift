import ConcurrencyExtras
import WPFoundation

// MARK: - TestDeviceOutputVolume

/// A ``DeviceOutputVolume`` conformance suitable as a mock during testing.
///
/// ## Usage
/// ```swift
/// func foo(volume: some DeviceOutputVolume) {
///   // Subscribe to the volume in here...
/// }
///
/// @Test("Receives Volume Updates")
/// func receives() async {
///   let volume = TestDeviceOutputVolume()
///   foo(volume: volume)
///   let status = DeviceOutputVolumeStatus(outputVolume: 0.38979)
///   await volume.send(result: .success(status)) // Send mock volume updates to foo
///   // Assertions...
/// }
/// ```
public final class TestDeviceOutputVolume: Sendable {
  private struct State {
    var subscribers = [UUID: @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void]()
    var buffer = [Result<DeviceOutputVolumeStatus, any Error>]()
  }

  private let subscribers = Lock(State())

  public init() {}
}

// MARK: - Sending Mock Result

extension TestDeviceOutputVolume {
  /// Sends a mock result to all of this volume's subscribers.
  ///
  /// - Parameter result: The mock result to send.
  public func send(result: Result<DeviceOutputVolumeStatus, any Error>) async {
    self.subscribers.withLock {
      $0.buffer.append(result)
      for callback in $0.subscribers.values {
        callback(result)
      }
    }
    await Task.megaYield()
  }
}

// MARK: - DeviceOutputVolume Conformance

extension TestDeviceOutputVolume: DeviceOutputVolume {
  public func subscribe(
    _ callback: @escaping @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    let id = UUID()
    self.subscribers.withLock {
      for result in $0.buffer {
        callback(result)
      }
      $0.subscribers[id] = callback
    }
    return DeviceOutputVolumeSubscription {
      _ = self.subscribers.withLock { $0.subscribers.removeValue(forKey: id) }
    }
  }
}
