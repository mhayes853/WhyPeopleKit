// MARK: - Capitalizing

extension StringProtocol {
  /// Returns a string with the first character of this string capitalized.
  @inlinable
  public var firstCharacterCapitalized: String {
    guard let first else { return "" }
    return first.uppercased() + self.dropFirst()
  }

  /// Returns a string with the first character of this string lowercased.
  @inlinable
  public var firstCharacterLowercased: String {
    guard let first else { return "" }
    return first.lowercased() + self.dropFirst()
  }
}

// MARK: - Positional Helpers

extension StringProtocol {
  /// Returns the character of the index immediately before the specified index.
  ///
  /// This string must be non-empty.
  ///
  /// - Parameter index: A valid index of the collection. `index` must be less than endIndex and
  /// greater than or equal to startIndex.
  /// - Returns: The character of the index immediately before the specified index.
  @inlinable
  public func character(before index: String.Index) -> Character? {
    precondition(!self.isEmpty, "String index out of bounds.")
    guard index > self.startIndex else { return nil }
    return self[self.index(before: index)]
  }

  /// Returns the character of the index immediately after the specified index.
  ///
  /// This string must be non-empty.
  ///
  /// - Parameter index: A valid index of the collection. `index` must be less than endIndex and
  /// greater than or equal to startIndex.
  /// - Returns: The character of the index immediately after the specified index.
  @inlinable
  public func character(after index: String.Index) -> Character? {
    precondition(!self.isEmpty, "String index out of bounds.")
    guard index < self.index(before: self.endIndex) else { return nil }
    return self[self.index(after: index)]
  }
}
