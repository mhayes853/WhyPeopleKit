import WPSilentModeSwitch

struct TestDeviceOutputVolume: DeviceOutputVolume {
  let statusUpdates: AsyncThrowingStream<DeviceOutputVolumeStatus, Error>
}
