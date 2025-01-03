extension StringProtocol {
  /// Returns the [Levenshtein Distance](https://en.wikipedia.org/wiki/Levenshtein_distance)
  /// between this string and another string.
  ///
  /// - Parameter other: The string to compare this string with.
  /// - Returns: The Levenshtein Distance.
  public func levenshteinDistance(from other: some StringProtocol) -> Int {
    var cache = Cache(left: self.count, right: other.count)
    return self.levenshteinDistance(
      from: other,
      currentKey: Cache.Key(),
      cache: &cache
    )
  }

  private func levenshteinDistance(
    from other: some StringProtocol,
    currentKey: Cache.Key,
    cache: inout Cache
  ) -> Int {
    if self.isEmpty {
      return other.count
    } else if other.isEmpty {
      return self.count
    } else if let value = cache[currentKey] {
      return value
    }
    let increment = self.last == other.last ? 0 : 1
    let value = Swift.min(
      self.dropLast()
        .levenshteinDistance(
          from: other,
          currentKey: currentKey.leftDropped,
          cache: &cache
        ) + 1,
      self.levenshteinDistance(
        from: other.dropLast(),
        currentKey: currentKey.rightDropped,
        cache: &cache
      ) + 1,
      self.dropLast()
        .levenshteinDistance(
          from: other.dropLast(),
          currentKey: currentKey.dropped,
          cache: &cache
        ) + increment
    )
    cache[currentKey] = value
    return value
  }
}

// MARK: - Cache

private struct Cache {
  private var array: [[Int?]]

  init(left: Int, right: Int) {
    self.array = [[Int?]](repeating: [Int?](repeating: nil, count: right + 1), count: left + 1)
  }

  subscript(key: Key) -> Int? {
    get { self.array[key.left][key.right] }
    set { self.array[key.left][key.right] = newValue }
  }
}

// MARK: - CacheKey

extension Cache {
  struct Key: Hashable {
    var left = 0
    var right = 0

    var leftDropped: Self {
      Self(left: self.left + 1, right: self.right)
    }

    var rightDropped: Self {
      Self(left: self.left, right: self.right + 1)
    }

    var dropped: Self {
      Self(left: self.left + 1, right: self.right + 1)
    }
  }
}
