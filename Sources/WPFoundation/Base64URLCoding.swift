import Foundation

extension Data {
  public func base64URLEncodedString() -> String {
    self.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

extension Data {
  public init?(base64URLEncoded: String) {
    var base64Encoded = base64URLEncoded
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
