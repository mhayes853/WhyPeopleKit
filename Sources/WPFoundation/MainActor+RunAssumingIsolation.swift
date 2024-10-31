import Foundation

extension MainActor {
  /// A backport of `MainActor.assumeIsolated`.
  @_unavailableFromAsync(message:"await the call to the @MainActor closure directly")
  public static func runAssumingIsolation<T: Sendable>(
    _ operation: @MainActor () throws -> T,
    file: StaticString = #fileID,
    line: UInt = #line
  ) rethrows -> T {
    #if swift(<5.10)
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
    #else
      return try assumeIsolated(operation, file: file, line: line)
    #endif
  }
}
