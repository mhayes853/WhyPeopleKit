import Foundation

// MARK: - Writing

extension NSFileCoordinator {
  public func coordinate<T>(
    writingItemAt url: URL,
    options: NSFileCoordinator.WritingOptions = [],
    byAccessor: (URL) throws -> T
  ) throws -> T {
    try self.coordinate { pointer, state in
      self.coordinate(readingItemAt: url, error: pointer) { url in
        state.perform { try byAccessor(url) }
      }
    }
  }
}

// MARK: - Reading

extension NSFileCoordinator {
  public func coordinate<T>(
    readingItemAt url: URL,
    options: NSFileCoordinator.ReadingOptions = [],
    byAccessor: (URL) throws -> T
  ) throws -> T {
    try self.coordinate { pointer, state in
      self.coordinate(readingItemAt: url, error: pointer) { url in
        state.perform { try byAccessor(url) }
      }
    }
  }
}

// MARK: - Reading and Writing

extension NSFileCoordinator {
  public func coordinate<T>(
    readingItemAt: URL,
    options readingOptions: NSFileCoordinator.ReadingOptions,
    writingItemAt: URL,
    options writingOptions: NSFileCoordinator.WritingOptions,
    byAccessor: (URL, URL) throws -> T
  ) throws -> T {
    try self.coordinate { pointer, state in
      self.coordinate(
        readingItemAt: readingItemAt,
        options: readingOptions,
        writingItemAt: writingItemAt,
        options: writingOptions,
        error: pointer
      ) { url1, url2 in
        state.perform { try byAccessor(url1, url2) }
      }
    }
  }
}

// MARK: - Writing and Writing

extension NSFileCoordinator {
  public func coordinate<T>(
    writingItemAt url1: URL,
    options options1: NSFileCoordinator.WritingOptions,
    writingItemAt url2: URL,
    options options2: NSFileCoordinator.WritingOptions,
    byAccessor: (URL, URL) throws -> T
  ) throws -> T {
    try self.coordinate { pointer, state in
      self.coordinate(
        writingItemAt: url1,
        options: options1,
        writingItemAt: url2,
        options: options2,
        error: pointer
      ) { url1, url2 in
        state.perform { try byAccessor(url1, url2) }
      }
    }
  }
}

// MARK: - Helper

private struct CoordinateState<T> {
  private(set) var value: T?
  private(set) var error: (any Error)?
  
  mutating func perform(_ work: () throws -> T) {
    do {
      self.value = try work()
    } catch {
      self.error = error
    }
  }
}

extension NSFileCoordinator {
  private func coordinate<T>(
    _ coordinate: (NSErrorPointer, inout CoordinateState<T>) throws -> Void
  ) throws -> T {
    var state = CoordinateState<T>()
    var coordinatorError: NSError?
    try coordinate(&coordinatorError, &state)
    if let error = coordinatorError ?? state.error {
      throw error
    }
    return state.value!
  }
}
