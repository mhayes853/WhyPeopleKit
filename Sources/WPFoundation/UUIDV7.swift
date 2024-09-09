import Foundation
#if canImport(AppIntents)
import AppIntents
#endif

// MARK: - UUIDV7

/// An RFC 9562 compliant UUID Version 7.
@dynamicMemberLookup
public struct UUIDV7: RawRepresentable {
  /// The underlying Foundation UUID of this UUID.
  public let rawValue: UUID
  
  public init?(rawValue: UUID) {
    let variant = rawValue.uuid.8 >> 6
    guard rawValue.version == 7, variant == 0b10 else { return nil }
    self.rawValue = rawValue
  }
}

// MARK: - Basic Initializers

extension UUIDV7 {
  /// Attempts to create a ``UUIDV7`` from a Foundation UUID.
  ///
  /// The Foundation UUID must be compliant with RFC 9562 UUID Version 7.
  ///
  /// - Parameter uuid: A Foundation UUID.
  @inlinable
  public init?(_ uuid: UUID) {
    self.init(rawValue: uuid)
  }
  
  /// Attempts to create a ``UUIDV7`` from a Foundation `uuid_t`.
  ///
  /// The Foundation UUID must be compliant with RFC 9562 UUID Version 7.
  ///
  /// - Parameter uuid: A Foundation `uuid_t`.
  @inlinable
  public init?(uuid: uuid_t) {
    self.init(UUID(uuid: uuid))
  }
  
  /// Attempts to create a ``UUIDV7`` from a UUID String.
  ///
  /// The UUID String must be compliant with RFC 9562 UUID Version 7.
  ///
  /// - Parameter uuidString: A UUID String.
  @inlinable
  public init?(uuidString: String) {
    guard let uuid = UUID(uuidString: uuidString) else { return nil }
    self.init(uuid)
  }
}

// MARK: - Dynamic Member Lookup

extension UUIDV7 {
  @inlinable
  public subscript<Value>(dynamicMember keyPath: KeyPath<UUID, Value>) -> Value {
    self.rawValue[keyPath: keyPath]
  }
}

// MARK: - Codable

extension UUIDV7: Encodable {
  @inlinable
  public func encode(to encoder: any Encoder) throws {
    try self.rawValue.encode(to: encoder)
  }
}

extension UUIDV7: Decodable {
  @inlinable
  public init(from decoder: any Decoder) throws {
    self.rawValue = try UUID(from: decoder)
  }
}

// MARK: - EntityIdentifierConvertible

#if canImport(AppIntents)
extension UUIDV7: EntityIdentifierConvertible {
  @inlinable
  public var entityIdentifierString: String {
    self.rawValue.entityIdentifierString
  }
  
  @inlinable
  public static func entityIdentifier(for entityIdentifierString: String) -> UUIDV7? {
    UUID.entityIdentifier(for: entityIdentifierString).flatMap(Self.init(rawValue:))
  }
}
#endif

// MARK: - CustomStringConvertible

extension UUIDV7: CustomStringConvertible {
  @inlinable
  public var description: String {
    self.rawValue.description
  }
}

// MARK: - CustomReflectable

extension UUIDV7: CustomReflectable {
  @inlinable
  public var customMirror: Mirror {
    self.rawValue.customMirror
  }
}

// MARK: - Basic Conformances

extension UUIDV7: Hashable {}
extension UUIDV7: Sendable {}
