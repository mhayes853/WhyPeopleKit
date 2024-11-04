#if canImport(GRDB)
  import GRDB
  import WPFoundation

  extension ApplicationLaunchID: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
      self.rawValue.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> ApplicationLaunchID? {
      UUIDV7.fromDatabaseValue(dbValue).map { ApplicationLaunchID(rawValue: $0) }
    }
  }
#endif
