import Foundation

// MARK: - Lock

/// A simple lock data type.
///
/// Use `Mutex` whenever possible, this type only exists for backwards compatability on platforms
/// that cannot use `Mutex` such as older versions of iOS.
public struct Lock<Value: ~Copyable>: ~Copyable {
  private let lock = NSLock()
  private var value: UnsafeMutablePointer<Value>

  /// Creates a lock by consuming the specified value.
  ///
  /// - Parameter value: The initial value of the lock.
  public init(_ value: consuming sending Value) {
    self.value = UnsafeMutablePointer<Value>.allocate(capacity: 1)
    self.value.initialize(to: value)
  }

  deinit { self.value.deallocate() }
}

// MARK: - WithLock

extension Lock {
  /// Calls the specified closure with the lock acquired and gives up ownership of the value.
  ///
  /// > Warning: Do not call this method from within `body`, this will cause a deadlock.
  ///
  /// - Parameter body: A closure with mutable access to the underlying value.
  /// - Returns: Whatever `body` returns.
  public borrowing func withLock<Result: ~Copyable, E: Error>(
    _ body: (inout sending Value) throws(E) -> sending Result
  ) throws(E) -> sending Result {
    self.lock.lock()
    defer { self.lock.unlock() }
    return try body(&self.value.pointee)
  }
}

// MARK: - Sendable

extension Lock: @unchecked Sendable where Value: ~Copyable {}

// MARK: - RecursiveLock

/// A simple lock data type that is also recursive.
///
/// This type behaves like `Mutex`, but allows threads that have acquired the lock to acquire it
/// again.
public struct RecursiveLock<Value: ~Copyable>: ~Copyable {
  private let lock = NSRecursiveLock()
  private var value: UnsafeMutablePointer<Value>

  /// Creates a lock by consuming the specified value.
  ///
  /// - Parameter value: The initial value of the lock.
  public init(_ value: consuming sending Value) {
    self.value = UnsafeMutablePointer<Value>.allocate(capacity: 1)
    self.value.initialize(to: value)
  }

  deinit { self.value.deallocate() }
}

// MARK: - WithLock

extension RecursiveLock {
  /// Calls the specified closure with the lock acquired and gives up ownership of the value.
  ///
  /// - Parameter body: A closure with mutable access to the underlying value.
  /// - Returns: Whatever `body` returns.
  public borrowing func withLock<Result: ~Copyable, E: Error>(
    _ body: (inout sending Value) throws(E) -> sending Result
  ) throws(E) -> sending Result {
    self.lock.lock()
    defer { self.lock.unlock() }
    return try body(&self.value.pointee)
  }
}

// MARK: - Sendable

extension RecursiveLock: @unchecked Sendable where Value: ~Copyable {}
