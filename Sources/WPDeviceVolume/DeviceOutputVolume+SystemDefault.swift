#if os(macOS)
/// The default ``DeviceOutputVolume`` for this device.
public typealias SystemDefaultDeviceOutputVolume = CoreAudioDeviceOutputVolume

extension DeviceOutputVolume where Self == SystemDefaultDeviceOutputVolume {
  /// Attempts to initialize the system default ``DeviceOutputVolume`` conformance.
  public static func systemDefault() throws -> SystemDefaultDeviceOutputVolume {
    try CoreAudioDeviceOutputVolume()
  }
}
#elseif os(watchOS)
/// The default ``DeviceOutputVolume`` for this device.
public typealias SystemDefaultDeviceOutputVolume = AVAudioSessionDeviceOutputVolume

extension DeviceOutputVolume where Self == SystemDefaultDeviceOutputVolume {
  /// Attempts to initialize the system default ``DeviceOutputVolume`` conformance.
  public static func systemDefault() throws -> SystemDefaultDeviceOutputVolume {
    try AVAudioSessionDeviceOutputVolume()
  }
}
#else
/// The default ``DeviceOutputVolume`` for this device.
public typealias SystemDefaultDeviceOutputVolume = _PingForMuteStatusDeviceVolume<
  AVAudioSessionDeviceOutputVolume,
  ContinuousClock
>

extension DeviceOutputVolume where Self == SystemDefaultDeviceOutputVolume {
  /// Attempts to initialize the system default ``DeviceOutputVolume`` conformance.
  public static func systemDefault() throws -> SystemDefaultDeviceOutputVolume {
    try AVAudioSessionDeviceOutputVolume().pingForMuteStatus()
  }
}
#endif
