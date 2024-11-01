import Foundation

extension Date {
  /// Creates a `Date` from a static ISO-8601 datestring.
  ///
  /// This initializer crashes if the string is in an invalid format.
  ///
  /// - Parameter staticISO8601: A `StaticString` in iso8601 format.
  public init(staticISO8601: StaticString) {
    self = formatter.withLock { $0.date(from: "\(staticISO8601)")! }
  }
}

private let formatter = Lock(ISO8601DateFormatter())
