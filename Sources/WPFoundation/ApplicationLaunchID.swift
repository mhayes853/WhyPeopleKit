import Foundation
import IssueReporting

// MARK: - ApplicationLaunchID

/// A data type that holds onto a unique id for every application launch.
///
/// This type serves as a stable identifier for the launch of an application unlike the current
/// process ID which may reuse the same value for different processes.
///
/// An instance of this type can only be returned through ``current``, and ``rawValue`` cannot be
/// changed outside of debug builds. In debug builds, you can use ``withNewValue`` to change the
/// raw value for the duration of an operation, which is useful for testing. ``withNewValue`` is
/// not available in release builds.
///
/// You can also store launch IDs in SQLite databases using WPGRDB since this type conforms to
/// `DatabaseValueConvertible` (only if you import WPGRDB).
public struct ApplicationLaunchID: Hashable, Sendable {
  /// The raw ID of this launch ID.
  ///
  /// This value is a ``UUIDV7`` which could be useful for comparing launch times.
  public let rawValue: UUIDV7

  package init(rawValue: UUIDV7) {
    self.rawValue = rawValue
  }
}

// MARK: - Current

extension ApplicationLaunchID {
  #if DEBUG
    @TaskLocal private static var _current = Self(rawValue: UUIDV7())

    /// Sets the underlying raw value of this launch id for the duration of an operation.
    ///
    /// If the operation uses a detached task, or runs outside the cooperative thread-pool, then
    /// the value overriden by this function will no longer be present.
    ///
    /// - Parameters:
    ///   - uuid: The new raw value.
    ///   - body: The operation to run with the new value.
    /// - Returns: Whatever `body` returns.
    public static func withNewValue<T>(
      _ uuid: UUIDV7 = UUIDV7(),
      _ body: @Sendable () throws -> T
    ) rethrows -> T {
      try Self.$_current.withValue(Self(rawValue: uuid), operation: body)
    }

    /// Sets the underlying raw value of this launch id for the duration of an operation.
    ///
    /// If the operation uses a detached task, or runs outside the cooperative thread-pool, then
    /// the value overriden by this function will no longer be present.
    ///
    /// - Parameters:
    ///   - uuid: The new raw value.
    ///   - body: The operation to run with the new value.
    /// - Returns: Whatever `body` returns.
    public static func withNewValue<T>(
      _ uuid: UUIDV7 = UUIDV7(),
      _ body: @Sendable () async throws -> T
    ) async rethrows -> T {
      try await Self.$_current.withValue(Self(rawValue: uuid), operation: body)
    }
  #else
    private static let _current = Self(rawValue: UUIDV7())
  #endif

  /// A stable identifier for this application launch.
  public static func current() -> Self { ._current }
}

// MARK: - Comparable

extension ApplicationLaunchID: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}
