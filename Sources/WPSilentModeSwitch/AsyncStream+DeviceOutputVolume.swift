extension AsyncStream: DeviceOutputVolume where Element == DeviceOutputVolumeStatus {
  public var statusUpdates: Self { self }
}

extension AsyncThrowingStream: DeviceOutputVolume where Element == DeviceOutputVolumeStatus {
  public var statusUpdates: Self { self }
}
