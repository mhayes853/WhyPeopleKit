import WPDeviceVolume

// MARK: - SystemDeviceOutputVolume

extension DependencyValues {
  /// The `DeviceOutputVolume` conformance that features should use when they want to read
  /// information about the device's global volume level or mute status.
  ///
  /// By default, a platform specific value is supplied that is determined by
  /// `SystemDefaultDeviceOutputVolume.systemDefault()`. If the initialization of the platform
  /// specific value fails, a ``FailingDeviceOutputVolume`` is returned instead.
  /// ``FailingDeviceOutputVolume`` allows you to inspect the error thrown by the initialization
  /// of the platform specific value.
  public var systemDeviceOutputVolume: any DeviceOutputVolume & Sendable {
    get { self[SystemDeviceOutputVolumeKey.self] }
    set { self[SystemDeviceOutputVolumeKey.self] = newValue }
  }
  
  private struct SystemDeviceOutputVolumeKey: DependencyKey {
    static var liveValue: any DeviceOutputVolume & Sendable {
      do {
        return try SystemDefaultDeviceOutputVolume.systemDefault()
      } catch {
        return FailingDeviceOutputVolume(error: error)
      }
    }
  }
}

// MARK: - FailingDeviceOutputVolume

/// A `DeviceOutputVolume` conformance that is returned when the dependency key for
/// ``Dependencies/DependencyValues/systemDeviceOutputVolume`` fails to initialize its default
/// value.
///
/// Subscribing to this conformance will immediately invoke the callback with the error thrown by
/// the default value initialization.
public struct FailingDeviceOutputVolume: DeviceOutputVolume, Sendable {
  /// The error that was thrown by the default value initialization.
  public let error: any Error
  
  public func subscribe(
    _ callback: @escaping (Result<DeviceOutputVolumeStatus, any Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    callback(.failure(self.error))
    return DeviceOutputVolumeSubscription {}
  }
}
