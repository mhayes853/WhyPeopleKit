// MARK: - TestFailable

/// A protocol for failing the current test case.
///
/// ``failCurrentTest(_:file:line:)`` will use the current instance of this protocol provided by
/// ``withTestFailable(_:operation:)-7zfuc``.
///
/// ```swift
/// import WPTestSupport
///
/// withTestFailable(SwiftTestingFailable()) {
///   failCurrentTest("We used swift testing to fail this test...")
/// }
/// ```
public protocol TestFailable {
  /// Fails the current test case.
  ///
  /// - Parameters:
  ///   - message: A message to fail the current test with.
  func failTest(_ message: String?, file: StaticString, line: UInt)
}

// MARK: - WithTestFailable

/// Overrides the ``TestFailable`` conformance for the duration of `operation`.
///
/// - Parameters:
///   - failable: The ``TestFailable`` to use.
///   - operation: The operation to perform.
/// - Throws: Whatever `operation` throws.
/// - Returns: Whatever `operation` returns.
public func withTestFailable<T>(
  _ failable: some TestFailable & Sendable,
  operation: @Sendable @escaping () throws -> T
) rethrows -> T {
  try TestAssetionsLocals.$testFailable.withValue(failable, operation: operation)
}

/// Overrides the ``TestFailable`` conformance for the duration of `operation`.
///
/// - Parameters:
///   - failable: The ``TestFailable`` to use.
///   - operation: The operation to perform.
/// - Throws: Whatever `operation` throws.
/// - Returns: Whatever `operation` returns.

public func withTestFailable<T>(
  _ failable: some TestFailable & Sendable,
  operation: @Sendable @escaping () async throws -> T
) async rethrows -> T {
  try await TestAssetionsLocals.$testFailable.withValue(failable, operation: operation)
}

// MARK: - FailCurrentTest

/// Fails the current test case.
///
/// This function is safe to use outside of a testing context, as it uses a dynamic overlay to
/// invoke the proper testing framework. When called outside a testing context, a runtime warning
/// will be issued.
///
/// By default, this function will detect whether or not Swift Testing, or XCTest is running, and
/// call the appropriate failure function. You can also use a custom testing framework by passing a
/// ``TestFailable`` conformance to ``withTestFailable(_:operation:)-1wdty``, and calling this
/// function within the operation closure.
///
/// - Parameters:
///   - message: A message to fail the current test with.
public func failCurrentTest(
  _ message: String? = nil,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  if let testFailable = TestAssetionsLocals.testFailable {
    testFailable.failTest(message, file: file, line: line)
  } else {
#if DEBUG
    _runtimeWarn(message ?? "", file: file, line: line)
#endif
  }
}

// MARK: - Helpers

public var _canFailCurrentTest: Bool {
  TestAssetionsLocals.testFailable != nil
}

private enum TestAssetionsLocals {
  @TaskLocal static var testFailable: (any TestFailable & Sendable)? = defaultTestFailable
}

package protocol DefaultTestFailable: TestFailable, Sendable {}

private let defaultTestFailable: (any DefaultTestFailable)? = {
  NSClassFromString("_DefaultTestFailable")
    .flatMap { $0 as Any as? NSObjectProtocol }
    .flatMap {
      let failable = $0.perform(Selector(("current")))?.takeUnretainedValue()
      return failable as? any DefaultTestFailable
    }
}()
