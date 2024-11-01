#if !os(Linux)
  import Foundation

  /// A `Sendable` conforming `NSUbiquitousKeyValueStore` subclass.
  ///
  /// `NSUbiquitousKeyValueStore` is thread-safe, but isn't marked as `Sendable` because it can be
  /// subclassed, therefore since this subclass is final, we can safely mark it as `@unchecked Sendable`.
  public final class SendableUbiquitousKeyValueStore: NSUbiquitousKeyValueStore, @unchecked Sendable
  {
    private static let _default = SendableUbiquitousKeyValueStore()
    public override class var `default`: SendableUbiquitousKeyValueStore { Self._default }
  }
#endif
