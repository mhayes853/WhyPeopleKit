#if canImport(GRDB)
  import GRDB
  import UUIDV7
  import WPFoundation

  extension ApplicationLaunchID: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
      self.rawValue.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> ApplicationLaunchID? {
      UUID.fromDatabaseValue(dbValue).flatMap { UUIDV7($0) }
        .map { ApplicationLaunchID(rawValue: $0) }
    }
  }
#endif
