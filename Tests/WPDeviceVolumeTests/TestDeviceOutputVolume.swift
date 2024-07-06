import WPDeviceVolume

struct TestDeviceOutputVolume: DeviceOutputVolume {
  let statusUpdates: AsyncThrowingStream<DeviceOutputVolumeStatus, Error>
  
  func subscribe(
    _ callback: @escaping @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    let task = Task {
      do {
        for try await status in self.statusUpdates {
          callback(.success(status))
        }
      } catch {
        callback(.failure(error))
      }
    }
    return DeviceOutputVolumeSubscription { task.cancel() }
  }
}

struct NoopDeviceOutputVolume: DeviceOutputVolume {
  func subscribe(
    _ callback: @escaping @Sendable (Result<DeviceOutputVolumeStatus, any Error>) -> Void
  ) -> DeviceOutputVolumeSubscription {
    DeviceOutputVolumeSubscription {}
  }
}
