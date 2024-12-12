#if canImport(GRDB)
  import WPFoundation

  extension UUIDV7: DatabaseValueConvertible, StatementColumnConvertible {}
#endif
