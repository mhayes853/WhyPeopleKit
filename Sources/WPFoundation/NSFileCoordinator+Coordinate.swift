import Foundation

// MARK: - Writing

extension NSFileCoordinator {
  public func coordinate<T>(
    writingItemAt url: URL,
    options: NSFileCoordinator.WritingOptions = [],
    byAccessor: (URL) throws -> T
  ) throws -> T {
    var value: T?
    var coordinatorError: NSError?
    var operationError: (any Error)?
    self.coordinate(writingItemAt: url, options: options, error: &coordinatorError) { url in
      do {
        value = try byAccessor(url)
      } catch {
        operationError = error
      }
    }
    if let error = coordinatorError ?? operationError {
      throw error
    }
    return value!
  }
}

// MARK: - Reading

extension NSFileCoordinator {
  public func coordinate<T>(
    readingItemAt url: URL,
    options: NSFileCoordinator.ReadingOptions = [],
    byAccessor: (URL) throws -> T
  ) throws -> T {
    var value: T?
    var coordinatorError: NSError?
    var operationError: (any Error)?
    self.coordinate(readingItemAt: url, options: options, error: &coordinatorError) { url in
      do {
        value = try byAccessor(url)
      } catch {
        operationError = error
      }
    }
    if let error = coordinatorError ?? operationError {
      throw error
    }
    return value!
  }
}
