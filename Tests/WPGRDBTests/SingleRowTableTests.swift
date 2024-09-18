import Testing
import WPGRDB

@Suite("SingleRowTable tests")
struct SingleRowTableTests {
  @Suite("SingleRowTableRecord tests")
  struct SingleRowRecordTests {
    private let queue = try! DatabaseQueue()

    init() async throws {
      try await self.queue.write { db in
        try db.create(table: "test") { table in
          table.singleRowTablePrimaryKey("id")
          table.column("text", .text).notNull()
        }
      }
    }

    @Test("Can Update Non-Inserted Record")
    func updatesNonInserted() async throws {
      let record = try await self.queue.write { db in
        try TestRecord.update(db) { $0.text = "Foo" }
        return try TestRecord.find(db)
      }
      #expect(record == TestRecord(text: "Foo"))
    }
  }

  @Suite("TableDefinition+SingleRowTableID tests")
  struct TableDefinitionSingleRowTableIDTests {
    @Test("Accepts Single Insert")
    func acceptsSingle() async throws {
      let queue = try DatabaseQueue()
      try await queue.write { db in
        try db.create(table: "test") { table in
          table.singleRowTablePrimaryKey("id")
          table.column("text", .text)
        }
      }
      try await queue.write { db in
        try db.execute(literal: "INSERT INTO test (id, text) VALUES (1, 'hello')")
        let strings = try String.fetchAll(db, sql: "SELECT text FROM test")
        #expect(strings == ["hello"])
      }
    }

    @Test("Rejects Multiple Inserts")
    func rejectsMultipleInserts() async throws {
      let queue = try DatabaseQueue()
      try await queue.write { db in
        try db.create(table: "test") { table in
          table.singleRowTablePrimaryKey("id")
          table.column("text", .text)
        }
      }
      await #expect(throws: DatabaseError.self) {
        try await queue.write { db in
          try db.execute(literal: "INSERT INTO test (id, text) VALUES (1, 'hello')")
          try db.execute(literal: "INSERT INTO test (id, text) VALUES (2, 'world')")
        }
      }
    }

    @Test("Replaces on Conflict")
    func replacesConflict() async throws {
      let queue = try DatabaseQueue()
      try await queue.write { db in
        try db.create(table: "test") { table in
          table.singleRowTablePrimaryKey("id")
          table.column("text", .text)
        }
      }
      try await queue.write { db in
        try db.execute(literal: "INSERT INTO test (id, text) VALUES (1, 'hello')")
        try db.execute(literal: "INSERT INTO test (id, text) VALUES (1, 'world')")
        let strings = try String.fetchAll(db, sql: "SELECT text FROM test")
        #expect(strings == ["world"])
      }
    }
  }
}

private struct TestRecord: Hashable, Sendable, Codable, SingleRowTableRecord {
  static let databaseTableName = "test"

  private(set) var id = 1
  var text = ""
}
