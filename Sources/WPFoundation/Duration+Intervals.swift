extension Duration {
  /// Construct a `Duration` given a number of minutes represented as a `BinaryInteger`.
  ///
  /// ```swift
  /// let d: Duration = .minutes(77)
  /// ```
  ///
  /// - Returns: A `Duration` representing a given number of minutes.
  @inlinable
  public static func minutes(_ minutes: some BinaryInteger) -> Self {
    .seconds(minutes * 60)
  }

  /// Construct a `Duration` given a number of hours represented as a `BinaryInteger`.
  ///
  /// ```swift
  /// let d: Duration = .hours(77)
  /// ```
  ///
  /// - Returns: A `Duration` representing a given number of hours.
  @inlinable
  public static func hours(_ hours: some BinaryInteger) -> Self {
    .minutes(hours * 60)
  }

  /// Construct a `Duration` given a number of days represented as a `BinaryInteger`.
  ///
  /// ```swift
  /// let d: Duration = .days(77)
  /// ```
  ///
  /// - Returns: A `Duration` representing a given number of days.
  @inlinable
  public static func days(_ days: some BinaryInteger) -> Self {
    .hours(days * 24)
  }

  /// Construct a `Duration` given a number of weeks represented as a `BinaryInteger`.
  ///
  /// ```swift
  /// let d: Duration = .weeks(77)
  /// ```
  ///
  /// - Returns: A `Duration` representing a given number of weeks.
  @inlinable
  public static func weeks(_ weeks: some BinaryInteger) -> Self {
    .days(weeks * 7)
  }
}
