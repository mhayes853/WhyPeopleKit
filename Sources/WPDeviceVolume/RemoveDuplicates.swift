import os

func removeDuplicates(
  _ fn: @Sendable @escaping (Result<DeviceOutputVolumeStatus, Error>) -> Void
) -> @Sendable (Result<DeviceOutputVolumeStatus, Error>) -> Void {
  let value = OSAllocatedUnfairLock<DeviceOutputVolumeStatus?>(initialState: nil)
  return { result in
    switch result {
    case let .success(status):
      value.withLock {
        if $0 != status {
          $0 = status
          fn(.success(status))
        }
      }
    case let .failure(error):
      fn(.failure(error))
    }
  }
}
