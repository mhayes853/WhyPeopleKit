// MARK: - SilentModeStatus

/// The current status of the device's volume silence.
///
/// This status represents whether or not the device's ringer is off, or if the system
/// volume is zero.
public enum SilentModeStatus: Hashable, Sendable {
  /// The device is currently muted.
  case noVolume
  
  /// The device is not muted.
  case hasVolume
  
  /// The device's ringer is off, or a hardware mute switch is on.
  ///
  /// - Parameter hasVolume: Whether or not the device has volume despite hardware silent mode being on.
  case hardwareSilentModeOn(hasVolume: Bool)
}

// MARK: - SilentMode

/// A protocol for reading and observing the status of the device's volume silence.
///
/// This protocol detects whether or not the device's ringer is off, or if the system volume is
/// zero.
public protocol SilentMode {
  associatedtype StatusUpdates: AsyncSequence where StatusUpdates.Element == SilentModeStatus
  
  /// An `AsyncSequence` broadcasting updates to silent mode.
  var statusUpdates: StatusUpdates { get }
}
