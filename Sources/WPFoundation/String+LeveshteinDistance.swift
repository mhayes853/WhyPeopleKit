extension StringProtocol {
  /// Returns the [Levenshtein Distance](https://en.wikipedia.org/wiki/Levenshtein_distance)
  /// between this string and another string.
  ///
  /// - Parameter other: The string to compare this string with.
  /// - Returns: The Levenshtein Distance.
  public func levenshteinDistance(from other: some StringProtocol) -> Int {
    self._levenshteinDistance(from: other, threshold: .max) ?? .max
  }

  /// Returns true if the [Levenshtein Distance](https://en.wikipedia.org/wiki/Levenshtein_distance)
  /// between this string and the other string are less than a given threshold.
  ///
  /// - Parameters:
  ///   - other: The string to compare this string with.
  ///   - distance: The threshold distance.
  /// - Returns: True if the Levenshtein Distance is less than the threshold.
  public func isUnderLevenshteinDistance(_ other: some StringProtocol, distance: Int) -> Bool {
    self._levenshteinDistance(from: other, threshold: distance) != nil
  }

  private func _levenshteinDistance(from other: some StringProtocol, threshold: Int) -> Int? {
    let len1 = self.count
    let len2 = other.count
    guard abs(len1 - len2) <= threshold else { return nil }

    var prevRow = [Int](0...len2)
    var currRow = [Int](repeating: 0, count: len2 + 1)

    for (i, c1) in self.enumerated() {
      currRow[0] = i + 1
      var minInRow = currRow[0]

      var jIndex = other.startIndex
      for j in 0..<len2 {
        let cost = (c1 == other[jIndex]) ? 0 : 1
        let insertion = currRow[j] + 1
        let deletion = prevRow[j + 1] + 1
        let substitution = prevRow[j] + cost

        currRow[j + 1] = Swift.min(insertion, deletion, substitution)
        minInRow = Swift.min(minInRow, currRow[j + 1])
        jIndex = other.index(after: jIndex)
      }

      if minInRow > threshold {
        return nil
      }

      swap(&prevRow, &currRow)
    }

    let result = prevRow[len2]
    return result > threshold ? nil : result
  }
}
