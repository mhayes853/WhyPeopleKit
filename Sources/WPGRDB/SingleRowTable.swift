import GRDB

// MARK: - SingleRowTableRecord

public protocol SingleRowTableRecord: FetchableRecord, PersistableRecord, TableRecord {
  init()
}

extension SingleRowTableRecord {
  public func willUpdate(_ db: Database, columns: Set<String>) throws {
    if try !self.exists(db) {
      try Self().insert(db)
    }
  }
  
  public static func find(_ db: Database) throws -> Self {
    try Self.fetchOne(db) ?? Self()
  }
  
  public static func update<T>(_ db: Database, update: (inout Self) throws -> T) throws -> T {
    var record = try Self.find(db)
    let value = try update(&record)
    try record.update(db)
    return value
  }
}

// MARK: - TableDefinition

extension TableDefinition {
  @discardableResult
  public func singleRowTablePrimaryKey(_ name: String) -> ColumnDefinition {
    self.primaryKey(name, .integer, onConflict: .replace)
      .check { $0 == 1 }
  }
}
