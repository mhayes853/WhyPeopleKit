#if canImport(GRDB)
  import GRDB

  // MARK: - SingleRowTableRecord

  /// A type that is stored as the sole row of a table.
  public protocol SingleRowTableRecord: FetchableRecord, PersistableRecord, TableRecord {
    init()
  }

  extension SingleRowTableRecord {
    public func willUpdate(_ db: Database, columns: Set<String>) throws {
      if try !self.exists(db) {
        try Self().insert(db)
      }
    }

    /// Returns the sole record from the database.
    ///
    /// - Parameter db: A database connection.
    public static func find(_ db: Database) throws -> Self {
      try Self.fetchOne(db) ?? Self()
    }

    /// Performs an update on the sole record from the database.
    ///
    /// - Parameters:
    ///   - db: A database connection.
    ///   - update: A closure to update the record.
    /// - Returns: Whatever `update` returns.
    public static func update<T>(_ db: Database, update: (inout Self) throws -> T) throws -> T {
      var record = try Self.find(db)
      let value = try update(&record)
      try record.update(db)
      return value
    }
  }

  // MARK: - TableDefinition

  extension TableDefinition {
    /// Appends a primary key column that only allows a single record to be stored in this table.
    ///
    /// The value of the primary key must always be an integer with a value equal to 1.
    ///
    /// - Parameter name: The column name.
    /// - Returns: A ``ColumnDefinition`` that allows you to refine the column definition.
    @discardableResult
    public func singleRowTablePrimaryKey(_ name: String) -> ColumnDefinition {
      self.primaryKey(name, .integer, onConflict: .replace)
        .check { $0 == 1 }
    }
  }
#endif
