import os

final class RemoveDuplicatesState: Sendable {
  private let value = OSAllocatedUnfairLock<DeviceOutputVolumeStatus?>(initialState: nil)
  private let callback: @Sendable (Result<DeviceOutputVolumeStatus, Error>) -> Void

  init(
    _ callback: @Sendable @escaping (Result<DeviceOutputVolumeStatus, Error>) -> Void
  ) {
    self.callback = callback
  }

  func emit(error: any Error) {
    self.callback(.failure(error))
  }

  func emit(_ update: @Sendable (inout DeviceOutputVolumeStatus) throws -> Void) rethrows {
    try self.value.withLock { value in
      var newValue = value ?? DeviceOutputVolumeStatus(outputVolume: 0)
      try update(&newValue)
      if value != newValue {
        self.callback(.success(newValue))
      }
      value = newValue
    }
  }
}
