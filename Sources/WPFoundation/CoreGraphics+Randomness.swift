import CoreGraphics

// MARK: - CGRect Random Points

extension CGRect {
  /// A random point in this rect.
  ///
  /// - Returns: A `CGPoint`.
  public func randomPoint() -> CGPoint {
    var generator = SystemRandomNumberGenerator()
    return self.randomPoint(using: &generator)
  }
  
  /// A random point in this rect.
  ///
  /// - Parameter generator: The random number generator to use when selecting the random point.
  /// - Returns: A `CGPoint`.
  public func randomPoint(using generator: inout some RandomNumberGenerator) -> CGPoint {
    let x = CGFloat.random(in: self.minX...self.maxX, using: &generator)
    let y = CGFloat.random(in: self.minY...self.maxY, using: &generator)
    return CGPoint(x: x, y: y)
  }
}

// MARK: - Random Squares

extension CGSize {
  
  /// Returns a random size with an equal width and height.
  ///
  /// - Parameter range: The range in which to create a random value. Must be finite.
  /// - Returns: A `CGSize` with an equal width and height from a random value within the bounds of `range`.
  public static func randomSquare(in range: Range<CGFloat>) -> Self {
    var generator = SystemRandomNumberGenerator()
    return .randomSquare(in: range, using: &generator)
  }
  
  /// Returns a random size with an equal width and height.
  ///
  /// - Parameters:
  ///   - range: The range in which to create a random value. Must be finite.
  ///   - generator: The random number generator to use when creating the new random value.
  /// - Returns: A `CGSize` with an equal width and height from a random value within the bounds of `range`.
  public static func randomSquare(
    in range: Range<CGFloat>,
    using generator: inout some RandomNumberGenerator
  ) -> Self {
    let size = CGFloat.random(in: range.lowerBound...range.upperBound, using: &generator)
    return CGSize(width: size, height: size)
  }
}
