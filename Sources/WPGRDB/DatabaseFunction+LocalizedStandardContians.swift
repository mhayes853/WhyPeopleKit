#if canImport(GRDB)
  import Foundation
  @preconcurrency import GRDB

  extension DatabaseFunction {
    /// A `DatabaseFunction` for localized standard contains on Strings.
    public static let localizedStandardContains = DatabaseFunction(
      "LOCALIZED_STANDARD_CONTAINS",
      argumentCount: 2,
      pure: true
    ) { dbValues in
      guard let a = String.fromDatabaseValue(dbValues[0]),
        let b = String.fromDatabaseValue(dbValues[1])
      else { return false }
      return a.localizedStandardContains(b)
    }

    /// A `DatabaseFunction` for localized case insensitive contains on Strings.
    public static let localizedCaseInsensitiveContains = DatabaseFunction(
      "LOCALIZED_CASE_INSENSITIVE_CONTAINS",
      argumentCount: 2,
      pure: true
    ) { dbValues in
      guard let a = String.fromDatabaseValue(dbValues[0]),
        let b = String.fromDatabaseValue(dbValues[1])
      else { return false }
      return a.localizedCaseInsensitiveContains(b)
    }
  }
#endif
