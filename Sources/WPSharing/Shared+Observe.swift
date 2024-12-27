import Perception
import Sharing
import WPSwiftNavigation

// MARK: - _Shareable

public protocol _Shareable<Value>: Perceptible, Sendable {
  associatedtype Value
  var wrappedValue: Value { get }
}

// MARK: - Observe

extension _Shareable {
  public func observe(_ fn: @Sendable @escaping (Value) -> Void) -> ObserveToken {
    WPSwiftNavigation.observe { fn(self.wrappedValue) }
  }
}

// MARK: - SharedValues

public struct SharedValues<Value: Sendable>: AsyncSequence {
  fileprivate let shareable: any _Shareable<Value>

  public func makeAsyncIterator() -> AsyncStream<Value>.AsyncIterator {
    let stream = AsyncStream<Value> { continuation in
      let token = self.shareable.observe { continuation.yield($0) }
      continuation.onTermination = { @Sendable _ in token.cancel() }
    }
    return stream.makeAsyncIterator()
  }
}

extension _Shareable where Value: Sendable {
  public var values: SharedValues<Value> {
    SharedValues(shareable: self)
  }
}

// MARK: - Conformances

extension Shared: _Shareable {}
extension SharedReader: _Shareable {}
