import Foundation

// MARK: - Lock

public struct Lock<Value: ~Copyable>: ~Copyable {
  private let lock = NSLock()
  private var value: UnsafeMutablePointer<Value>

  public init(_ value: consuming sending Value) {
    self.value = UnsafeMutablePointer<Value>.allocate(capacity: 1)
    self.value.initialize(to: value)
  }

  deinit { self.value.deallocate() }
}

// MARK: - WithLock

extension Lock {
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
