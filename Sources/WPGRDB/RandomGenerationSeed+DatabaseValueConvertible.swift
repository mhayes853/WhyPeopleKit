#if canImport(GRDB)
  import GRDB
  import WPFoundation

  // NB: Sqlite cannnot store 64-bit unsigned integers, so we'll convert to and from a string instead.

  extension RandomGenerationSeed: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
      DatabaseValue(value: "\(self.rawValue)")!
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> RandomGenerationSeed? {
      switch dbValue.storage {
      case let .int64(x): RandomGenerationSeed(rawValue: UInt64(truncatingIfNeeded: x))
      case let .string(text): UInt64(text).map { Self(rawValue: $0) }
      default: nil
      }
    }
  }
#endif
