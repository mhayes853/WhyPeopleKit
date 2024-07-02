// MARK: - DeviceVolumeStatus

/// A status of a device's volume.
public struct DeviceVolumeStatus: Hashable, Sendable {
  /// The amount of volume in in the range [0, 1].
  public let decibals: Double
  
  /// Whether or not the device is muted through hardware or software means.
  ///
  /// Only iOS and macOS have mechanisms to detect if the device is muted.
  @available(macOS 13, iOS 16, *)
  public let isMuted: Bool
  
  /// Iniitializes a ``DeviceVolumeStatus`` instance.
  ///
  /// - Parameters:
  ///   - decibals: The amount of volume in in the range [0, 1].
  ///   - isMuted: Whether or not the device is muted through hardware or software means.
  @available(macOS 13, iOS 16, *)
  public init(decibals: Double, isMuted: Bool) {
    self.decibals = decibals
    self.isMuted = isMuted
  }
  
  /// Iniitializes a ``DeviceVolumeStatus`` instance.
  ///
  /// - Parameters:
  ///   - decibals: The amount of volume in in the range [0, 1].
  public init(decibals: Double) {
    self.decibals = decibals
    self.isMuted = false
  }
}

extension DeviceVolumeStatus {
  /// Whether or not the volume decibals is not totally silent.
  public var hasVolume: Bool {
    self.decibals > 0
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
