import Foundation

// MARK: - StaticID

/// An ID which is always the same and is primarily useful as a primary key field for single row
/// database tables.
public struct StaticID: Hashable, Sendable {
  public init() {}
}

// MARK: - Encodable

extension StaticID: Encodable {
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(1)
  }
}

// MARK: - Decodable

extension StaticID: Decodable {
  public init(from decoder: any Decoder) throws {
    let value = try decoder.singleValueContainer().decode(Int.self)
    guard value == 1 else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: [],
          debugDescription: "Expected value to be 1, but was \(value)"
        )
      )
    }
    self = StaticID()
  }
}
