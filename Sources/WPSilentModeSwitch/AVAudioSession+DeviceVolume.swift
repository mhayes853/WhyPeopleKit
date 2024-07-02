import AVFoundation
import AsyncAlgorithms

// MARK: - SilentMode Conformance

@available(macOS, unavailable)
extension AVAudioSession: DeviceOutputVolume {
  public typealias StatusUpdates = AsyncRemoveDuplicatesSequence<
    AsyncThrowingStream<DeviceOutputVolumeStatus, Error>
  >
  
  /// An `AsyncSequence` of status updates for the current ``DeviceOutputVolumeStatus``.
  ///
  /// This sets this audio session to be active.
  ///
  /// This conformance of ``DeviceOutputVolume`` cannot detect if the device is muted through hardware
  /// of software means.
  public var statusUpdates: StatusUpdates {
    AsyncThrowingStream<DeviceOutputVolumeStatus, Error> { continuation in
      do {
        try self.setActive(true, options: [])
      } catch {
        continuation.finish(throwing: error)
      }
      let observer = self.observe(\.outputVolume, options: [.initial, .new]) { session, _ in
        continuation.yield(DeviceOutputVolumeStatus(outputVolume: Double(session.outputVolume)))
      }
      continuation.onTermination = { @Sendable _ in observer.invalidate() }
    }
    .removeDuplicates()
  }
}
