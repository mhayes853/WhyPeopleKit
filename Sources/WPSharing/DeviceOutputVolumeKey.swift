#if !os(Linux)
  import Sharing
  import WPDependencies
  import WPDeviceVolume

  #if canImport(SwiftUI)
    import SwiftUI
  #endif

  // MARK: - SystemDeviceOutputVolumeKey

  /// A shared key for the system device output volume.
  public struct SystemDeviceOutputVolumeKey: Sendable {
    private let volume: any DeviceOutputVolume & Sendable
    #if canImport(SwiftUI)
      private let animation: Animation?
    #endif

    #if canImport(SwiftUI)
      fileprivate init(animation: Animation? = nil) {
        @Dependency(\.systemDeviceOutputVolume) var volume
        self.volume = volume
        self.animation = animation
      }
    #else
      fileprivate init() {
        @Dependency(\.systemDeviceOutputVolume) var volume
        self.volume = volume
      }
    #endif
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
        #if canImport(SwiftUI)
          withBackgroundAnimation(self.animation) {
            subscriber.yield(with: result.map { $0 as Value? })
          }
        #else
          subscriber.yield(with: result.map { $0 as Value? })
        #endif
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

    #if canImport(SwiftUI)
      public static func systemDeviceOutputVolume(_ animation: Animation? = nil) -> Self {
        Self[
          SystemDeviceOutputVolumeKey(animation: animation),
          default: DeviceOutputVolumeStatus(outputVolume: 0)
        ]
      }
    #endif
  }

  // MARK: - ID

  public struct SystemDeviceOutputVolumeKeyID: Hashable {
    private let id: ObjectIdentifier
    #if canImport(SwiftUI)
      private let animation: Animation?
    #endif

    #if canImport(SwiftUI)
      fileprivate init(volume: any DeviceOutputVolume, animation: Animation?) {
        self.id = ObjectIdentifier(volume as AnyObject)
        self.animation = animation
      }
    #else
      fileprivate init(volume: any DeviceOutputVolume) {
        self.id = ObjectIdentifier(volume as AnyObject)
      }
    #endif
  }

  extension SystemDeviceOutputVolumeKey {
    public var id: SystemDeviceOutputVolumeKeyID {
      #if canImport(SwiftUI)
        SystemDeviceOutputVolumeKeyID(volume: self.volume, animation: self.animation)
      #else
        SystemDeviceOutputVolumeKeyID(volume: self.volume)
      #endif
    }
  }
#endif
