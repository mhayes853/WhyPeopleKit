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
  associatedtype StatusUpdates: AsyncSequence where StatusUpdates.Element == DeviceOutputVolumeStatus
  
  /// An `AsyncSequence` of status updates for the current ``DeviceOutputVolumeStatus``.
  var statusUpdates: StatusUpdates { get }
}
