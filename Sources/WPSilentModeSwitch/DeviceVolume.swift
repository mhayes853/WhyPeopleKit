// MARK: - DeviceVolumeStatus

/// A status of a device's volume.
public struct DeviceVolumeStatus: Hashable, Sendable {
  /// The amount of volume in in the range [0, 1].
  public let outputVolume: Double
  
  /// Whether or not the device is muted through hardware or software means.
  ///
  /// watchOS does not have a mechanism to detect if the device is globally muted.
  @available(watchOS, unavailable)
  public let isMuted: Bool
  
  /// Iniitializes a ``DeviceVolumeStatus`` instance.
  ///
  /// - Parameters:
  ///   - decibals: The amount of volume in in the range [0, 1].
  ///   - isMuted: Whether or not the device is muted through hardware or software means.
  @available(watchOS, unavailable)
  public init(outputVolume: Double, isMuted: Bool) {
    self.outputVolume = outputVolume
    self.isMuted = isMuted
  }
  
  /// Iniitializes a ``DeviceVolumeStatus`` instance.
  ///
  /// - Parameters:
  ///   - decibals: The amount of volume in in the range [0, 1].
  public init(outputVolume: Double) {
    self.outputVolume = outputVolume
    self.isMuted = false
  }
}

extension DeviceVolumeStatus {
  /// Whether or not the volume decibals is not totally silent.
  public var hasVolume: Bool {
    self.outputVolume > 0
  }
  
  /// Returns true if the device does not have volume, or if it is muted.
  public var isSilent: Bool {
    !self.hasVolume || self.isMuted
  }
}

// MARK: - SilentMode

/// A protocol for reading and observing the status of the device's volume.
public protocol DeviceVolume {
  associatedtype StatusUpdates: AsyncSequence where StatusUpdates.Element == DeviceVolumeStatus
  
  /// An `AsyncSequence` of status updates for the current ``DeviceVolumeStatus``.
  var statusUpdates: StatusUpdates { get }
}
