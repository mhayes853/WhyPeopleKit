import Foundation

// MARK: - Encoding

extension Data {
  /// Returns a Base-64 url-encoded string.
  ///
  /// - returns: The Base-64 url-encoded string.
  public func base64URLEncodedString() -> String {
    self.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

// MARK: - Decoding

extension Data {
  /// Initialize a `Data` from a Base-64 encoded String.
  ///
  /// Returns nil when the input is not recognized as valid Base-64.
  /// - parameter base64URLEncoded: The string to parse.
  public init?(base64URLEncoded: String) {
    var base64Encoded =
      base64URLEncoded
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    let byteLength = Double(base64Encoded.lengthOfBytes(using: .utf8))
    base64Encoded = base64Encoded.padding(
      toLength: Int(ceil(byteLength / 4.0) * 4),
      withPad: "=",
      startingAt: 0
    )
    self.init(base64Encoded: base64Encoded)
  }
}
