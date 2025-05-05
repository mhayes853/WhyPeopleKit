#if canImport(WPGRDB) && canImport(SharingGRDB)
  import CustomDump
  import Testing
  import WPDependencies
  import WPFoundation
  import WPGRDBSharing

  @Suite("AsyncSingleRowTableKey tests")
  struct AsyncSingleRowTableKeyTests {
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
      await Task.megaYield()
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
      await Task.megaYield()
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
      await Task.megaYield()
      // NB: Shared will perform a main thread hop when setting the value.
      await MainActor.run {
        expectNoDifference(record, newRecord)
      }
    }

    @Test("Forwards Error When Database Initialization Fails")
    func forwardsWhenInitializationFails() async throws {
      @Shared(.failingTestRecord) var record
      await Task.megaYield()
      expectNoDifference($record.loadError as? FailingWriter.SomeError, FailingWriter.SomeError())
    }
  }

  extension SharedKey where Self == AsyncSingleRowTableKey<TestRecord>.Default {
    fileprivate static func testRecord(_ database: DatabaseQueue) -> Self {
      Self[.asyncSingleRowTableRecord(database: .constant(database)), default: TestRecord()]
    }
  }

  extension SharedKey where Self == AsyncSingleRowTableKey<TestRecord>.Default {
    fileprivate static var failingTestRecord: Self {
      Self[.asyncSingleRowTableRecord(database: FailingWriter()), default: TestRecord()]
    }
  }

  private final class FailingWriter: AsyncInitializedDatabaseWriter {
    struct SomeError: Equatable, Error {}

    var writer: any DatabaseWriter {
      get throws { throw SomeError() }
    }
  }

  private struct TestRecord: SingleRowTableRecord, Codable, Hashable, Sendable {
    static let databaseTableName = "test"

    var id = StaticID()
    var name = "blob"
  }
#endif
