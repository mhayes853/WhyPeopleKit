#if canImport(GRDB)
  import GRDB
  import WPFoundation

  // MARK: - DatabaseValueConvertible

  extension StaticID: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
      DatabaseValue(value: 1)!
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Self? {
      guard case let .int64(int) = dbValue.storage else { return nil }
      return int != 1 ? nil : Self()
    }
  }
#endif
