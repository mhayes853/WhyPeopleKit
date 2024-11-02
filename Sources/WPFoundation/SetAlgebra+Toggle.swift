extension SetAlgebra {
  /// Inserts the specified element if it does not exist in this set or removes the element
  /// otherwise.
  ///
  /// - Parameter member: The member to toggle.
  @inlinable
  public mutating func toggle(_ member: Element) {
    if self.contains(member) {
      self.remove(member)
    } else {
      self.insert(member)
    }
  }
}
