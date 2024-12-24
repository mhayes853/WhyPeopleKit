import Sharing
import WPDependencies
import WPDeviceVolume

// MARK: - SystemDeviceOutputVolumeKey

/// A shared key for the system device output volume.
public struct SystemDeviceOutputVolumeKey: Sendable {
  private let volume: any DeviceOutputVolume & Sendable

  fileprivate init() {
    @Dependency(\.systemDeviceOutputVolume) var volume
    self.volume = volume
  }
}

// MARK: - SharedReaderKey Conformance

extension SystemDeviceOutputVolumeKey: SharedReaderKey {
  public typealias Value = DeviceOutputVolumeStatus

  public func load(initialValue: Value?) -> Value? {
    nil
  }

  public func subscribe(
    initialValue: Value?,
    didSet receiveValue: @escaping @Sendable (Value?) -> Void
  ) -> SharedSubscription {
    let subscription = self.volume.subscribe { result in
      _ = result.map { receiveValue($0) }
    }
    return SharedSubscription { subscription.cancel() }
  }
}

extension SharedReaderKey where Self == SystemDeviceOutputVolumeKey.Default {
  /// A shared key for the system device output volume.
  ///
  /// You can override the source of the device volume by overriding the `systemDeviceOutputVolume`
  /// dependency.
  ///
  /// ```swift
  /// @Test("Status")
  /// func status()  {
  ///   let volume = TestDeviceOutputVolume()
  ///   withDependencies {
  ///     // Mock the volume source to be a mock source
  ///     $0.systemDeviceOutputVolume = volume
  ///   } operation: {
  ///     @SharedReader(.systemDeviceOutputVolume) var status
  ///     // Assertions...
  ///   }
  /// }
  /// ```
  public static var systemDeviceOutputVolume: Self {
    Self[SystemDeviceOutputVolumeKey(), default: DeviceOutputVolumeStatus(outputVolume: 0)]
  }
}

// MARK: - ID

public struct SystemDeviceOutputVolumeKeyID: Hashable {}

extension SystemDeviceOutputVolumeKey {
  public var id: SystemDeviceOutputVolumeKeyID {
    SystemDeviceOutputVolumeKeyID()
  }
}
