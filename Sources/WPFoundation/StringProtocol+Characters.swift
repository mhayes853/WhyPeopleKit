extension StringProtocol {
  /// Returns a string with the first character of this string capitalized.
  public var firstCharacterCapitalized: String {
    guard let first else { return "" }
    return first.uppercased() + self.dropFirst()
  }
}

extension StringProtocol {
  /// Returns the character of the index immediately before the specified index.
  ///
  /// This string must be non-empty.
  ///
  /// - Parameter index: A valid index of the collection. `index` must be less than endIndex and
  /// greater than or equal to startIndex.
  /// - Returns: The character of the index immediately before the specified index.
  public func character(before index: String.Index) -> Character? {
    // NB: Since you cannot index empty strings without crashing, we should preserve that behavior
    // by letting empty strings past the guard.
    guard self.isEmpty || index > self.startIndex else { return nil }
    return self[self.index(before: index)]
  }
  
  /// Returns the character of the index immediately after the specified index.
  ///
  /// This string must be non-empty.
  ///
  /// - Parameter index: A valid index of the collection. `index` must be less than endIndex and
  /// greater than or equal to startIndex.
  /// - Returns: The character of the index immediately after the specified index.
  public func character(after index: String.Index) -> Character? {
    guard index < self.index(before: self.endIndex) else { return nil }
    return self[self.index(after: index)]
  }
}
