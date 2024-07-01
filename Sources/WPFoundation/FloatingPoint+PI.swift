extension FloatingPoint {
  /// Returns this float times pi.
  ///
  /// This is useful for making mathematical calculations read more like traditional algebra. In
  /// other words `3.pi + 4` reads closer to `3π + 4` than `3 * .pi + 4`.
  @inlinable
  public var pi: Self {
    self * .pi
  }
}
