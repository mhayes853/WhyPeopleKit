#if os(macOS)
  /// The default ``DeviceOutputVolume`` for this device.
  public typealias SystemDefaultDeviceOutputVolume = CoreAudioDeviceOutputVolume

  extension DeviceOutputVolume where Self == SystemDefaultDeviceOutputVolume {
    /// Attempts to initialize the system default ``DeviceOutputVolume`` conformance.
    public static func systemDefault() throws -> SystemDefaultDeviceOutputVolume {
      try CoreAudioDeviceOutputVolume()
    }
  }
#elseif !os(iOS) && !os(Linux)
  /// The default ``DeviceOutputVolume`` for this device.
  public typealias SystemDefaultDeviceOutputVolume = AVAudioSessionDeviceOutputVolume

  extension DeviceOutputVolume where Self == SystemDefaultDeviceOutputVolume {
    /// Attempts to initialize the system default ``DeviceOutputVolume`` conformance.
    public static func systemDefault() throws -> SystemDefaultDeviceOutputVolume {
      try AVAudioSessionDeviceOutputVolume()
    }
  }
#elseif os(iOS)
  /// The default ``DeviceOutputVolume`` for this device.
  public typealias SystemDefaultDeviceOutputVolume = _PingForMuteStatusDeviceVolume<
    AVAudioSessionDeviceOutputVolume,
    DispatchPingTimer
  >

  extension DeviceOutputVolume where Self == SystemDefaultDeviceOutputVolume {
    /// Attempts to initialize the system default ``DeviceOutputVolume`` conformance.
    public static func systemDefault() throws -> SystemDefaultDeviceOutputVolume {
      try AVAudioSessionDeviceOutputVolume().pingForMuteStatus()
    }
  }
#endif
