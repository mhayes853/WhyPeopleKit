/// Returns true if 2 Equatable existential values are equal to each other.
///
/// - Parameters:
///   - value: The value.
///   - other: The other value.
/// - Returns: True if `value` and `other` have the same underlying type and equal values.
public func equals(_ value: any Equatable, _ other: any Equatable) -> Bool {
  _equals(value, other)
}

private func _equals<T: Equatable>(_ value: T, _ other: any Equatable) -> Bool {
  value == (other as? T)
}
