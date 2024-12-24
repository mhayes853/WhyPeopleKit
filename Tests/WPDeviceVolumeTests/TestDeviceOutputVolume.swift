import WPDeviceVolume

struct NoopDeviceOutputVolume: DeviceOutputVolume {
  func subscribe(
    _ callback: @escaping @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    DeviceOutputVolumeSubscription {}
  }
}
