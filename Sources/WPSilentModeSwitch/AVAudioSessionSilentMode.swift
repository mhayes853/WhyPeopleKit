import AVFoundation
import AsyncAlgorithms

// MARK: - AVAudioSessionSilentMode

/// A ``SilentMode`` mode conformance that uses `AVAudioSession` to detect if the system volume is
/// muted.
///
/// This conformance cannot detect the ringer position.
@available(macOS, unavailable)
public final class AVAudioSessionSilentMode: Sendable {
  public let session: AVAudioSession
  
  /// Attempts to create an ``AVAudioSessionSilentMode`` instance using a specified
  /// `AVAudioSession`.
  ///
  /// This initializer will attempt to set `session` to be active, and throws if this fails.
  ///
  /// - Parameter session: The `AVAudioSession` to observe the output volume from.
  public init(session: AVAudioSession = .sharedInstance()) throws {
    try session.setActive(true, options: [])
    self.session = session
  }
}

// MARK: - SilentMode Conformance

@available(macOS, unavailable)
extension AVAudioSessionSilentMode: SilentMode {
  public typealias Updates = AsyncRemoveDuplicatesSequence<AsyncStream<SilentModeStatus>>
  
  public var updates: Updates {
    AsyncStream<SilentModeStatus> { continuation in
      let observer = self.session.observe(\.outputVolume, options: [.initial, .new]) { session, _ in
        continuation.yield(session.outputVolume > 0 ? .hasVolume : .noVolume)
      }
      continuation.onTermination = { @Sendable _ in observer.invalidate() }
    }
    .removeDuplicates()
  }
}
