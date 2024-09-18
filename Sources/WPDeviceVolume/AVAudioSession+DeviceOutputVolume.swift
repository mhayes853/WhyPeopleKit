import AVFoundation

// MARK: - AVAudioSessionDeviceOutputVolume

/// An ``DeviceOutputVolume`` conformance that uses `AVAudioSession` to detect the output volume
/// of the device.
///
/// This instance cannot detect ``DeviceOutputVolumeStatus/isMuted``, and it will always by false
/// for status updates on this conformance.
@available(macOS, unavailable)
public final class AVAudioSessionDeviceOutputVolume: Sendable {
  public let session: AVAudioSession

  /// Attempts to initialize an ``AVAudioSessionDeviceOutputVolume`` by setting the specified
  /// `AVAudioSession` to active.
  ///
  /// Setting the underlying session to active is necessary to observe the output volume.
  ///
  /// - Parameter session: The `AVAudioSession` to use.
  public init(
    session: AVAudioSession = .sharedInstance(),
    options: AVAudioSession.SetActiveOptions = []
  ) throws {
    try session.setActive(true, options: options)
    self.session = session
  }
}

// MARK: - DeviceOutputVolume Conformance

@available(macOS, unavailable)
extension AVAudioSessionDeviceOutputVolume: DeviceOutputVolume {
  public func subscribe(
    _ callback: @Sendable @escaping (Result<DeviceOutputVolumeStatus, Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    let state = RemoveDuplicatesState(callback)
    let observer = self.session.observe(
      \.outputVolume,
      options: [.initial, .new]
    ) { session, _ in
      let status = DeviceOutputVolumeStatus(outputVolume: Double(session.outputVolume))
      state.emit { $0 = status }
    }
    return DeviceOutputVolumeSubscription { observer.invalidate() }
  }
}
