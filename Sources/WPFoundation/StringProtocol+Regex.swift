extension StringProtocol {
  /// Returns a match if this string is matched by the given regex in its entirety.
  ///
  /// - Parameter regex: The regular expression to match.
  /// - Returns: The match, if one is found. If there is no match, or a
  ///   transformation in `regex` throws an error, this method returns `nil`.
  public func wholeMatch<R: RegexComponent>(
    in regexComponent: R
  ) -> Regex<R.RegexOutput>.Match? {
    if let substring = self as? Substring {
      substring.wholeMatch(of: regexComponent)
    } else if let string = self as? String {
      string.wholeMatch(of: regexComponent)
    } else {
      String(self).wholeMatch(of: regexComponent)
    }
  }
}
