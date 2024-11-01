/// A data type representing an email address.
public struct EmailAddress: Hashable, Sendable, Codable, RawRepresentable {
  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}
