import WPDeviceVolume

struct TestDeviceOutputVolume: DeviceOutputVolume {
  let statusUpdates: AsyncThrowingStream<DeviceOutputVolumeStatus, Error>
}
