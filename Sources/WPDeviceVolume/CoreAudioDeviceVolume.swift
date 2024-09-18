import CoreAudio
import WPFoundation

#if os(macOS)
  import AudioToolbox

  // MARK: - CoreAudioDeviceVolume

  /// A ``DeviceOutputVolume`` conformance that uses CoreAudio to listen for whether or not the device if
  /// muted.
  public final class CoreAudioDeviceOutputVolume: Sendable {
    private let deviceId: AudioDeviceID

    /// Attempts to initialize a ``CoreAudioDeviceOutputVolume`` instance.
    ///
    /// This initializer fails if the default output device id cannot be found.
    public init() throws {
      guard let deviceId = try _defaultOutputDeviceId() else {
        throw CoreAudioError(OSStatus(kAudioObjectUnknown))
      }
      self.deviceId = deviceId
    }

    /// Initializes a ``CoreAudioDeviceOutputVolume`` with a specified `AudioDeviceID`.
    ///
    /// - Parameter deviceId: The `AudioDeviceID` to use.
    public init(_ deviceId: AudioDeviceID) {
      self.deviceId = deviceId
    }
  }

  // MARK: - DeviceOutputVolume Conformance

  extension CoreAudioDeviceOutputVolume: DeviceOutputVolume {
    public func subscribe(
      _ callback: @Sendable @escaping (Result<DeviceOutputVolumeStatus, any Error>) -> Void
    ) -> DeviceOutputVolumeSubscription {
      let state = RemoveDuplicatesState(callback)
      self.emitCurrentStatus(state)
      nonisolated(unsafe) let muteListenerBlock: AudioObjectPropertyListenerBlock = {
        [weak self] _, _ in
        self?.emitCurrentStatus(state)
      }
      nonisolated(unsafe) let volumeListenerBlock: AudioObjectPropertyListenerBlock = {
        [weak self] _, _ in
        self?.emitCurrentStatus(state)
      }
      _ = withUnsafePointer(to: _mutePropertyAddress) {
        AudioObjectAddPropertyListenerBlock(self.deviceId, $0, nil, muteListenerBlock)
      }
      _ = withUnsafePointer(to: _volumePropertyAddress) {
        AudioObjectAddPropertyListenerBlock(self.deviceId, $0, nil, volumeListenerBlock)
      }
      return DeviceOutputVolumeSubscription {
        _ = withUnsafePointer(to: _mutePropertyAddress) {
          AudioObjectRemovePropertyListenerBlock(self.deviceId, $0, nil, muteListenerBlock)
        }
        _ = withUnsafePointer(to: _volumePropertyAddress) {
          AudioObjectRemovePropertyListenerBlock(self.deviceId, $0, nil, volumeListenerBlock)
        }
      }
    }

    private func emitCurrentStatus(_ state: RemoveDuplicatesState) {
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
        state.emit(error: CoreAudioError(status))
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
        state.emit(error: CoreAudioError(status))
        return
      }
      let deviceVolumeStatus = DeviceOutputVolumeStatus(
        outputVolume: Double(outputVolume),
        isMuted: muted == 1
      )
      state.emit { $0 = deviceVolumeStatus }
    }
  }

  public func _defaultOutputDeviceId() throws -> AudioDeviceID? {
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
