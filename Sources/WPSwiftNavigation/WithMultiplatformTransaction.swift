import SwiftNavigation

#if canImport(SwiftUI)
  import SwiftUI
#endif

/// Executes a closure with the specified transaction and returns the result.
///
/// Unlike `withUITransaction` this function will also apply animations to SwiftUI views based on
/// the `swiftUI` property of `UITransaction`, and if whether or not the current platform can
/// import SwiftUI.
///
/// - Parameters:
///   - transaction: An instance of a transaction, set as the thread's current transaction.
///   - body: A closure to execute.
/// - Returns: The result of executing the closure with the specified transaction.
public func withMultiplatformTransaction<Result>(
  _ transaction: UITransaction,
  _ body: () throws -> Result
) rethrows -> Result {
  #if canImport(SwiftUI)
    try withUITransaction(transaction) {
      try withTransaction(transaction.swiftUI.transaction) {
        try body()
      }
    }
  #else
    try withUITransaction(transaction, body)
  #endif
}

/// Executes a closure with the specified transaction key path and value and returns the result.
///
/// Unlike `withUITransaction` this function will also apply animations to SwiftUI views based on
/// the `swiftUI` property of `UITransaction`, and if whether or not the current platform can
/// import SwiftUI.
///
/// - Parameters:
///   - keyPath: A key path that indicates the property of the ``UITransaction`` structure to
///     update.
///   - value: The new value to set for the item specified by `keyPath`.
///   - body: A closure to execute.
/// - Returns: The result of executing the closure with the specified transaction value.
public func withMultiplatformTransaction<R, V>(
  _ keyPath: WritableKeyPath<UITransaction, V>,
  _ value: V,
  _ body: () throws -> R
) rethrows -> R {
  var transaction = UITransaction()
  transaction[keyPath: keyPath] = value
  return try withMultiplatformTransaction(transaction, body)
}
