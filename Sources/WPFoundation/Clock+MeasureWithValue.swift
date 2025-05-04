@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
extension Clock {
  public func measureWithValue<T>(
    _ action: () async throws -> T
  ) async rethrows -> (Duration, T) {
    var value: T?
    let time = try await self.measure {
      value = try await action()
    }
    return (time, value!)
  }

  public func measureWithValue<T>(
    _ action: () throws -> T
  ) rethrows -> (Duration, T) {
    var value: T?
    let time = try self.measure {
      value = try action()
    }
    return (time, value!)
  }
}
