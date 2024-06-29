import Foundation

extension MainActor {
  /// A backport of `MainActor.assumeIsolated`.
  ///
  /// Assume that the current task is executing on the main actor's
  /// serial executor, or stop program execution.
  ///
  /// This method allows to *assume and verify* that the currently
  /// executing synchronous function is actually executing on the serial
  /// executor of the MainActor.
  ///
  /// If that is the case, the operation is invoked with an `isolated` version
  /// of the actor, / allowing synchronous access to actor local state without
  /// hopping through asynchronous boundaries.
  ///
  /// If the current context is not running on the actor's serial executor, or
  /// if the actor is a reference to a remote actor, this method will crash
  /// with a fatal error (similar to `preconditionIsolated()`).
  ///
  /// This method can only be used from synchronous functions, as asynchronous
  /// functions should instead perform a normal method call to the actor, which
  /// will hop task execution to the target actor if necessary.
  ///
  /// - Note: This check is performed against the MainActor's serial executor,
  ///   meaning that / if another actor uses the same serial executor--by using
  ///   `MainActor/sharedUnownedExecutor` as its own
  ///   `Actor/unownedExecutor`--this check will succeed , as from a concurrency
  ///   safety perspective, the serial executor guarantees mutual exclusion of
  ///   those two actors.
  ///
  /// - Parameters:
  ///   - operation: the operation that will be executed if the current context
  ///                is executing on the MainActor's serial executor.
  ///   - file: The file name to print if the assertion fails. The default is
  ///           where this method was called.
  ///   - line: The line number to print if the assertion fails The default is
  ///           where this method was called.
  /// - Returns: the return value of the `operation`
  /// - Throws: rethrows the `Error` thrown by the operation if it threw
  @_alwaysEmitIntoClient
  @_unavailableFromAsync(message: "await the call to the @MainActor closure directly")
  public static func runAssumingIsolation<T: Sendable>(
    _ operation: @MainActor () throws -> T,
    file: StaticString = #fileID,
    line: UInt = #line
  ) rethrows -> T {
    if #available(iOS 17, macOS 14, watchOS 10, tvOS 17, *) {
      return try Self.assumeIsolated(operation, file: file, line: line)
    }
    guard Thread.isMainThread else {
      fatalError(
        "Incorrect actor executor assumption; Expected same executor as \(self).",
        file: file,
        line: line
      )
    }
    // NB: To do the unsafe cast, we have to pretend it's @escaping.
    return try withoutActuallyEscaping(operation) {
      try unsafeBitCast($0, to: (() throws -> T).self)()
    }
  }
}
