@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
extension Clock {
  /// Measure the elapsed time to execute an asynchronous closure.
  ///
  ///       let clock = ContinuousClock()
  ///       let (elapsed, returnValue) = await clock.measureWithValue {
  ///          await someWork()
  ///       }
  public func measureWithValue<T>(
    isolation: isolated (any Actor)? = #isolation,
    _ work: () async throws -> T
  ) async rethrows -> (Duration, T) {
    var value: T?
    let time = try await self.measure {
      value = try await work()
    }
    return (time, value!)
  }

  /// Measure the elapsed time to execute a closure.
  ///
  ///       let clock = ContinuousClock()
  ///       let (elapsed, returnValue) = clock.measureWithValue {
  ///          someWork()
  ///       }
  public func measureWithValue<T>(
    _ work: () throws -> T
  ) rethrows -> (Duration, T) {
    var value: T?
    let time = try self.measure {
      value = try work()
    }
    return (time, value!)
  }
}
