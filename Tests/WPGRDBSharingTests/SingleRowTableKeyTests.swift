#if canImport(WPGRDB)
  import CustomDump
  import Testing
  import WPDependencies
  import WPFoundation
  import WPGRDBSharing

  @Suite("SingleRowTableKey tests")
  struct SingleRowTableKeyTests {
    private let database = try! DatabaseQueue()

    init() async throws {
      try await self.database.write { db in
        try db.create(table: TestRecord.databaseTableName) { table in
          table.singleRowTablePrimaryKey("id")
          table.column("name", .text).notNull()
        }
      }
    }

    @Test("Persists To Database")
    func persists() async throws {
      @Shared(.testRecord(self.database)) var record
      expectNoDifference(record, TestRecord())

      $record.withLock { $0.name = "blob jr" }
      expectNoDifference(record, TestRecord(name: "blob jr"))

      let newRecord = try await self.database.read { try TestRecord.find($0) }
      expectNoDifference(record, newRecord)
    }

    @Test("Loads Initial Value From Database")
    func loadsInitial() async throws {
      let newRecord = TestRecord(name: "blob jr")
      try await self.database.write { db in
        try TestRecord.update(db) { $0 = newRecord }
      }

      @Shared(.testRecord(self.database)) var record
      expectNoDifference(record, newRecord)
    }

    @Test("Observes Database Updates")
    func observes() async throws {
      @Shared(.testRecord(self.database)) var record
      expectNoDifference(record, TestRecord())

      let newRecord = TestRecord(name: "blob jr")
      try await self.database.write { db in
        try TestRecord.update(db) { $0 = newRecord }
      }
      expectNoDifference(record, newRecord)
    }
  }

  extension SharedKey where Self == SingleRowTableKey<TestRecord>.Default {
    fileprivate static func testRecord(_ database: DatabaseQueue) -> Self {
      Self[.singleRowTableRecord(database: database), default: TestRecord()]
    }
  }

  private struct TestRecord: SingleRowTableRecord, Codable, Hashable, Sendable {
    static let databaseTableName = "test"

    var id = StaticID()
    var name = "blob"
  }
#endif
