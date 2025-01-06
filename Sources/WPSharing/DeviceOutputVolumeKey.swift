#if !os(Linux)
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

    public func load(context: LoadContext<Value>, continuation: LoadContinuation<Value>) {
      continuation.resumeReturningInitialValue()
    }

    public func subscribe(
      context: LoadContext<Value>,
      subscriber: SharedSubscriber<Value>
    ) -> SharedSubscription {
      let subscription = self.volume.subscribe { result in
        subscriber.yield(with: result.map { $0 as Value? })
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

  public struct SystemDeviceOutputVolumeKeyID: Hashable {
    private let id: ObjectIdentifier

    fileprivate init(volume: any DeviceOutputVolume) {
      self.id = ObjectIdentifier(volume as AnyObject)
    }
  }

  extension SystemDeviceOutputVolumeKey {
    public var id: SystemDeviceOutputVolumeKeyID {
      SystemDeviceOutputVolumeKeyID(volume: self.volume)
    }
  }
#endif
