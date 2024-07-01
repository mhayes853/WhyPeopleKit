extension Collection {
  /// Returns a `Range` with startIndex as the lower bound, and the endIndex as the upper bound.
  @inlinable
  public var indexRange: Range<Index> {
    self.startIndex..<self.endIndex
  }
}
