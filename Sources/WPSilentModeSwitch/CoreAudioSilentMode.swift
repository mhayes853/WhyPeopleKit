import CoreAudio
import AsyncAlgorithms
import WPFoundation

public typealias CoreAudioDeviceID = UInt32

#if os(macOS)

/// A ``SilentMode`` conformance that uses CoreAudio to listen for whether or not the device if
/// muted.
public final class CoreAudioSilentMode: Sendable {
  private let deviceId: CoreAudioDeviceID
  
  /// Attempts to initialize a ``CoreAudioSilentMode-2iozb`` instance.
  public init?() throws {
    guard let deviceId = try _defaultOutputDeviceId() else { return nil }
    self.deviceId = deviceId
  }
}

extension CoreAudioSilentMode: SilentMode {
  public typealias StatusUpdates = AsyncThrowingStream<SilentModeStatus, Error>
  
  public var statusUpdates: StatusUpdates {
    StatusUpdates { continuation in
      self.yieldCurrentStatus(continuation: continuation)
      let propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyMute,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain
      )
      // NB: This cannot be made explicitly sendable due to AudioObjectAddPropertyListenerBlock not
      // accepting a sendable closure. To avoid compiler errors in onTermination, we mark this as
      // unsafe.
      nonisolated(unsafe) let listenerBlock: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
        self?.yieldCurrentStatus(continuation: continuation)
      }
      _ = withUnsafePointer(to: propertyAddress) {
        AudioObjectAddPropertyListenerBlock(self.deviceId, $0, nil, listenerBlock)
      }
      continuation.onTermination = { @Sendable _ in
        _ = withUnsafePointer(to: propertyAddress) {
          AudioObjectRemovePropertyListenerBlock(self.deviceId, $0, nil, listenerBlock)
        }
      }
    }
  }

  private func yieldCurrentStatus(continuation: StatusUpdates.Continuation) {
    var muted: UInt32 = 0
    var propertySize = UInt32(MemoryLayout<UInt32>.size)
    var propertyAddress = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyMute,
      mScope: kAudioDevicePropertyScopeOutput,
      mElement: kAudioObjectPropertyElementMain
    )
    let status = AudioObjectGetPropertyData(
      self.deviceId,
      &propertyAddress,
      0,
      nil,
      &propertySize,
      &muted
    )
    if status != noErr {
      continuation.finish(throwing: CoreAudioError(status))
      return
    }
    continuation.yield(muted == 0 ? .hasVolume : .noVolume)
  }
}

public func _defaultOutputDeviceId() throws -> CoreAudioDeviceID? {
  var result = kAudioObjectUnknown
  var size = UInt32(MemoryLayout<AudioDeviceID>.size)
  var address = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDefaultOutputDevice,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )
  guard AudioObjectHasProperty(AudioObjectID(kAudioObjectSystemObject), &address) else {
    return nil
  }
  let status = AudioObjectGetPropertyData(
    AudioObjectID(kAudioObjectSystemObject),
    &address,
    0,
    nil,
    &size,
    &result
  )
  guard status == noErr else { throw CoreAudioError(status) }
  return result == kAudioObjectUnknown ? nil : result
}

#else

@available(macOS 13, *)
public final class CoreAudioSilentMode: Sendable {
  public init?() throws { fatalError() }
}

@available(macOS 13, *)
extension CoreAudioSilentMode: SilentMode {
  public typealias StatusUpdates = AsyncThrowingStream<SilentModeStatus, Error>
  
  public var statusUpdates: StatusUpdates {
    fatalError()
  }
}

@available(macOS 13, *)
public func _defaultOutputDeviceId() throws -> CoreAudioDeviceID? {
  fatalError()
}

#endif
