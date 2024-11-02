import Foundation

extension Data {
  /// Returns this data as a hex-encoded string.
  ///
  /// Eg. `"Hello World" -> "48656c6c6f2c20576f726c6421"`
  ///
  /// - Returns: A hex-encoded string.
  public func hexEncodedString() -> String {
    self.map { String(format: "%02x", $0) }.joined()
  }
}
