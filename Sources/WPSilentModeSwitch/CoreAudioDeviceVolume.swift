import CoreAudio
import AsyncAlgorithms
import WPFoundation

public typealias _AudioDeviceID = UInt32

#if os(macOS)
import AudioToolbox

// MARK: - CoreAudioDeviceVolume

/// A ``DeviceOutputVolume`` conformance that uses CoreAudio to listen for whether or not the device if
/// muted.
public final class CoreAudioDeviceOutputVolume: Sendable {
  private let deviceId: _AudioDeviceID
  
  /// Attempts to initialize a ``CoreAudioDeviceVolume`` instance.
  ///
  /// This initializer fails if the default output device id cannot be found.
  public init() throws {
    guard let deviceId = try _defaultOutputDeviceId() else {
      throw CoreAudioError(OSStatus(kAudioObjectUnknown))
    }
    self.deviceId = deviceId
  }
}

// MARK: - DeviceOutputVolume Conformance

extension CoreAudioDeviceOutputVolume: DeviceOutputVolume {
  public typealias StatusUpdates = AsyncRemoveDuplicatesSequence<
    AsyncThrowingStream<DeviceOutputVolumeStatus, Error>
  >
  
  public var statusUpdates: StatusUpdates {
    AsyncThrowingStream<DeviceOutputVolumeStatus, Error> { continuation in
      self.yieldCurrentStatus(continuation: continuation)
      // NB: This cannot be made explicitly sendable due to AudioObjectAddPropertyListenerBlock not
      // accepting a sendable closure. To avoid compiler errors in onTermination, we mark this as
      // unsafe.
      nonisolated(unsafe) let muteListenerBlock: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
        self?.yieldCurrentStatus(continuation: continuation)
      }
      nonisolated(unsafe) let volumeListenerBlock: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
        self?.yieldCurrentStatus(continuation: continuation)
      }
      _ = withUnsafePointer(to: _mutePropertyAddress) {
        AudioObjectAddPropertyListenerBlock(self.deviceId, $0, nil, muteListenerBlock)
      }
      _ = withUnsafePointer(to: _volumePropertyAddress) {
        AudioObjectAddPropertyListenerBlock(self.deviceId, $0, nil, volumeListenerBlock)
      }
      continuation.onTermination = { @Sendable _ in
        _ = withUnsafePointer(to: _mutePropertyAddress) {
          AudioObjectRemovePropertyListenerBlock(self.deviceId, $0, nil, muteListenerBlock)
        }
        _ = withUnsafePointer(to: _volumePropertyAddress) {
          AudioObjectRemovePropertyListenerBlock(self.deviceId, $0, nil, volumeListenerBlock)
        }
      }
    }
    .removeDuplicates()
  }

  private func yieldCurrentStatus(
    continuation: AsyncThrowingStream<DeviceOutputVolumeStatus, Error>.Continuation
  ) {
    var muted = UInt32(0)
    var outputVolume = Float(0)
    var mutePropertySize = UInt32(MemoryLayout<UInt32>.size)
    var volumePropertySize = UInt32(MemoryLayout<Float>.size)
    var status = withUnsafePointer(to: _mutePropertyAddress) {
      AudioObjectGetPropertyData(
        self.deviceId,
        $0,
        0,
        nil,
        &mutePropertySize,
        &muted
      )
    }
    if status != noErr {
      continuation.finish(throwing: CoreAudioError(status))
      return
    }
    status = withUnsafePointer(to: _volumePropertyAddress) {
      AudioObjectGetPropertyData(
        self.deviceId,
        $0,
        0,
        nil,
        &volumePropertySize,
        &outputVolume
      )
    }
    if status != noErr {
      continuation.finish(throwing: CoreAudioError(status))
      return
    }
    let deviceVolumeStatus = DeviceOutputVolumeStatus(
      outputVolume: Double(outputVolume),
      isMuted: muted == 1
    )
    continuation.yield(deviceVolumeStatus)
  }
}

public func _defaultOutputDeviceId() throws -> _AudioDeviceID? {
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

public let _mutePropertyAddress = AudioObjectPropertyAddress(
  mSelector: kAudioDevicePropertyMute,
  mScope: kAudioDevicePropertyScopeOutput,
  mElement: kAudioObjectPropertyElementMain
)

public let _volumePropertyAddress = AudioObjectPropertyAddress(
  mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
  mScope: kAudioObjectPropertyScopeOutput,
  mElement: kAudioObjectPropertyElementMain
)

#endif
