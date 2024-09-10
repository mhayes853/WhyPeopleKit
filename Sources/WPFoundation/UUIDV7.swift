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

// MARK: - Date

extension UUIDV7 {
  @inlinable
  public var date: Date {
    let t1 = UInt64(self.rawValue.uuid.0) << 40
    let t2 = UInt64(self.rawValue.uuid.1) << 32
    let t3 = UInt64(self.rawValue.uuid.2) << 24
    let t4 = UInt64(self.rawValue.uuid.3) << 16
    let t5 = UInt64(self.rawValue.uuid.4) << 8
    let t6 = UInt64(self.rawValue.uuid.5)
    return Date(timeIntervalSince1970: TimeInterval(t1 | t2 | t3 | t4 | t5 | t6) / 1000)
  }
}

// MARK: - Time Initializers

extension UUIDV7 {
  public init(_ date: Date = Date()) {
    self.init(date.timeIntervalSince1970)
  }
  
  public init(_ timeInterval: TimeInterval) {
    var bytes = UUID_NULL
    let fd = open("/dev/urandom", O_RDONLY)
    read(fd, &bytes, MemoryLayout<uuid_t>.size)
    close(fd)
    self.init(timeInterval, &bytes)
  }
  
  public init(_ date: Date, _ integer: UInt32) {
    self.init(date.timeIntervalSince1970, integer)
  }
  
  public init(_ timeInterval: TimeInterval, _ integer: UInt32) {
    var bytes = UUID_NULL
    let byteCount = Int(ceil(Double(integer.bitWidth - integer.leadingZeroBitCount) / 8.0))
    withUnsafeMutablePointer(to: &bytes) { ptr in
      withUnsafePointer(to: integer) { integerPtr in
        UnsafeMutableRawPointer(ptr).advanced(by: MemoryLayout<uuid_t>.size - byteCount)
          .copyMemory(from: integerPtr, byteCount: byteCount)
      }
    }
    self.init(timeInterval, &bytes)
  }
  
  private init(_ timeInterval: TimeInterval, _ bytes: inout uuid_t) {
    withUnsafePointer(to: UInt64(timeInterval * 1000).bigEndian) {
      let ptr = UnsafeRawPointer($0).advanced(by: 2)
        .assumingMemoryBound(to: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8).self)
      bytes.0 = ptr.pointee.0
      bytes.1 = ptr.pointee.1
      bytes.2 = ptr.pointee.2
      bytes.3 = ptr.pointee.3
      bytes.4 = ptr.pointee.4
      bytes.5 = ptr.pointee.5
    }
    bytes.6 = (bytes.6 & 0x0F) | 0x70
    bytes.8 = (bytes.8 & 0x3F) | 0x80
    self.rawValue = UUID(uuid: bytes)
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

// MARK: - Comparable

extension UUIDV7: Comparable {
  public static func < (lhs: UUIDV7, rhs: UUIDV7) -> Bool {
    withUnsafePointer(to: lhs.rawValue.uuid) { lhs in
      withUnsafePointer(to: rhs.rawValue.uuid) { rhs in
        memcmp(lhs, rhs, MemoryLayout<uuid_t>.size) < 0
      }
    }
  }
}

// MARK: - Basic Conformances

extension UUIDV7: Hashable {}
extension UUIDV7: Sendable {}
