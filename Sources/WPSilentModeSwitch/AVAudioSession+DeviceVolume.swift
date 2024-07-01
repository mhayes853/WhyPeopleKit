import AVFoundation
import AsyncAlgorithms

// MARK: - SilentMode Conformance

@available(macOS, unavailable)
extension AVAudioSession: DeviceVolume {
  public typealias StatusUpdates = AsyncRemoveDuplicatesSequence<
    AsyncThrowingStream<DeviceVolumeStatus, Error>
  >
  
  /// An `AsyncSequence` of status updates for the current ``DeviceVolumeStatus``.
  ///
  /// This sets this audio session to be active.
  ///
  /// This conformance of ``DeviceVolume`` cannot detect if the device is muted through hardware
  /// of software means.
  public var statusUpdates: StatusUpdates {
    AsyncThrowingStream<DeviceVolumeStatus, Error> { continuation in
      do {
        try self.setActive(true, options: [])
      } catch {
        continuation.finish(throwing: error)
      }
      let observer = self.observe(\.outputVolume, options: [.initial, .new]) { session, _ in
        continuation.yield(DeviceVolumeStatus(decibals: Double(session.outputVolume)))
      }
      continuation.onTermination = { @Sendable _ in observer.invalidate() }
    }
    .removeDuplicates()
  }
}
