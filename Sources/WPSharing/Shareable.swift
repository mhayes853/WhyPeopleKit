import Perception

// MARK: - _Shareable

public protocol _Shareable<Value>: Perceptible, Sendable {
  associatedtype Value
  var wrappedValue: Value { get }

  subscript<Member>(
    dynamicMember keyPath: KeyPath<Value, Member>
  ) -> SharedReader<Member> { get }
}

// MARK: - Conformances

extension Shared: _Shareable {}
extension SharedReader: _Shareable {}
