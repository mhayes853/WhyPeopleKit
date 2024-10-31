import Foundation

extension MainActor {
  /// Executes the given body closure on the main actor synchronously.
  ///
  /// - Parameters:
  ///   - resultType: The return type of the operation.
  ///   - operation: The operation to run.
  /// - Returns: Whatever `operation` returns.
  public static func runSync<T: Sendable>(
    resultType: T.Type = T.self,
    _ operation: @MainActor () throws -> T,
    file: StaticString = #file,
    line: UInt = #line
  ) rethrows -> T {
    if DispatchQueue.getSpecific(key: mainQueueKey) == value {
      try Self.runAssumingIsolation(operation, file: file, line: line)
    } else {
      try DispatchQueue.main.sync { try operation() }
    }
  }
}

private let mainQueueKey: DispatchSpecificKey<UInt8> = {
  let key = DispatchSpecificKey<UInt8>()
  DispatchQueue.main.setSpecific(key: key, value: value)
  return key
}()
private let value: UInt8 = 0
