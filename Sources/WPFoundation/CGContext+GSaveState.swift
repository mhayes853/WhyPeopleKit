import CoreGraphics

extension CGContext {
  /// Runs the specified closure after saving the GState and restores the previous GState after it
  /// has finished running.
  ///
  /// - Parameter work: The unit of work to run after saving the current GState.
  /// - Returns: The return value of `work`.
  @inlinable
  @discardableResult
  public func withGSaveState<T>(
    perform work: (CGContext) throws -> T
  ) rethrows -> T {
    self.saveGState()
    defer { self.restoreGState() }
    return try work(self)
  }
}
