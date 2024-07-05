// MARK: - DeviceOutputVolumeStatus

/// A status of a device's output volume.
public struct DeviceOutputVolumeStatus: Hashable, Sendable {
  /// The amount of volume in in the range [0, 1].
  public let outputVolume: Double
  
  /// Whether or not the device is muted through hardware or software means.
  ///
  /// watchOS does not have a mechanism to detect if the device is globally muted, so this property
  /// is always false.
  public let isMuted: Bool
  
  /// Iniitializes a ``DeviceOutputVolumeStatus`` instance.
  ///
  /// - Parameters:
  ///   - decibals: The amount of volume in in the range [0, 1].
  ///   - isMuted: Whether or not the device is muted through hardware or software means.
  @available(watchOS, unavailable)
  public init(outputVolume: Double, isMuted: Bool) {
    self.outputVolume = outputVolume
    self.isMuted = isMuted
  }
  
  /// Iniitializes a ``DeviceOutputVolumeStatus`` instance.
  ///
  /// - Parameters:
  ///   - decibals: The amount of volume in in the range [0, 1].
  public init(outputVolume: Double) {
    self.outputVolume = outputVolume
    self.isMuted = false
  }
}

extension DeviceOutputVolumeStatus {
  /// Whether or not the volume decibals is not totally silent.
  public var hasVolume: Bool {
    self.outputVolume > 0
  }
  
  /// Returns true if the device does not have volume, or if it is muted.
  public var isSilent: Bool {
    !self.hasVolume || self.isMuted
  }
}

// MARK: - DeviceOutputVolume

/// A protocol for reading and observing the status of the device's volume.
public protocol DeviceOutputVolume {
  /// Subscribes to ``DeviceOutputVolumeStatus`` updates from this volume.
  ///
  /// - Parameter callback: A callback to invoke when a new update is available.
  /// - Returns: A ``DeviceOutputVolumeSubscription``.
  func subscribe(
    _ callback: @Sendable @escaping (Result<DeviceOutputVolumeStatus, Error>) -> Void
  ) -> DeviceOutputVolumeSubscription
}

// MARK: - Status Updates

/// An `AsyncSequence` of status updates for the current ``DeviceOutputVolumeStatus``.
public typealias AsyncDeviceVolumeStatusUpdates = AsyncThrowingStream<
  DeviceOutputVolumeStatus,
  Error
>

extension DeviceOutputVolume {
  /// An `AsyncSequence` of status updates for the current ``DeviceOutputVolumeStatus``.
  public var statusUpdates: AsyncDeviceVolumeStatusUpdates {
    AsyncDeviceVolumeStatusUpdates { continuation in
      let subscription = self.subscribe { continuation.yield(with: $0) }
      continuation.onTermination = { @Sendable _ in subscription.cancel() }
    }
  }
}

// MARK: - Subscription

/// A subscription to use with a ``DeviceOutputVolume`` conformance.
///
/// You can initialize this type with a closure that runs when the subscription is cancelled. Use
/// that closure to cleanup any resources acquired by the subscription. The cancellation closure
/// is automatically invoked when the subscription is deallocated.
public final class DeviceOutputVolumeSubscription: Sendable {
  private let onCancel: @Sendable () -> Void
  
  /// Initializes a subscription with a closure that runs when the subscription is cancelled.
  /// 
  /// - Parameter onCancel: A closure to cleanup any resources used by the subscription.
  public init(onCancel: @Sendable @escaping () -> Void) {
    self.onCancel = onCancel
  }
  
  deinit {
    self.cancel()
  }
  
  /// Cancels this subscription.
  public func cancel() {
    self.onCancel()
  }
}
