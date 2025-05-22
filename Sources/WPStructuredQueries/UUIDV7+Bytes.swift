import StructuredQueries
import WPFoundation

// MARK: - BytesRepresentation

extension UUIDV7 {
  public struct BytesRepresentation: QueryRepresentable {
    public var queryOutput: UUIDV7

    public init(queryOutput: UUIDV7) {
      self.queryOutput = queryOutput
    }
  }
}

// MARK: - Optional Support

extension Optional where Wrapped == UUIDV7 {
  public typealias BytesRepresentation = UUIDV7.BytesRepresentation?
}

// MARK: - QueryBindable Conformance

extension UUIDV7.BytesRepresentation: QueryBindable {
  public var queryBinding: QueryBinding {
    .blob(withUnsafeBytes(of: queryOutput.uuid, [UInt8].init))
  }
}

// MARK: - QueryDecodable Conformance

extension UUIDV7.BytesRepresentation: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    let queryOutput = try [UInt8](decoder: &decoder)
    guard queryOutput.count == 16 else { throw InvalidBytes() }
    let output = queryOutput.withUnsafeBytes {
      UUIDV7(uuid: $0.load(as: uuid_t.self))
    }
    guard let output else { throw InvalidBytes() }
    self.init(queryOutput: output)
  }

  private struct InvalidBytes: Error {}
}

// MARK: - SQLiteType Conformance

extension UUIDV7.BytesRepresentation: SQLiteType {
  public static var typeAffinity: SQLiteTypeAffinity {
    [UInt8].typeAffinity
  }
}
