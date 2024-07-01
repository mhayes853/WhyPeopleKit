extension StringProtocol {
  public var firstCharacterCapitalized: String {
    guard let first else { return "" }
    return first.uppercased() + self.dropFirst()
  }
}

extension StringProtocol {
  public func character(before index: String.Index) -> Character? {
    guard index > self.startIndex else { return nil }
    return self[self.index(before: index)]
  }
  
  public func character(after index: String.Index) -> Character? {
    guard index < self.index(before: self.endIndex) else { return nil }
    return self[self.index(after: index)]
  }
}
