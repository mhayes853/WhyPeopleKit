import CustomDump
import StructuredQueriesSQLite
import Testing
import WPFoundation
import WPStructuredQueries

@Suite("UUIDV7+Bytes tests")
struct UUIDV7BytesTests {
  private let database: Database

  init() throws {
    self.database = try Database()
    try self.database.execute(
      """
      CREATE TABLE test (id BLOB PRIMARY KEY NOT NULL)
      """
    )
  }

  @Test("Insert Regular UUID Into Table, Has Decoding Error")
  func insertRegularUUIDDecodingError() throws {
    let id = UUID()
    try self.database.execute(
      #sql(
        """
        INSERT INTO test (id) VALUES (\(UUID.BytesRepresentation(queryOutput: id)))
        """,
        as: Void.self
      )
    )

    #expect(throws: Error.self) {
      try self.database.execute(TestRecord.all)
    }
  }

  @Test("Insert And Select UUIDV7 From Table")
  func insertAndSelectUUIDV7FromTable() throws {
    let id = UUIDV7()
    try self.database.execute(
      #sql(
        """
        INSERT INTO test (id) VALUES (\(UUIDV7.BytesRepresentation(queryOutput: id)))
        """,
        as: Void.self
      )
    )

    let records = try self.database.execute(TestRecord.all)
    expectNoDifference(records, [TestRecord(id: id)])
  }
}

@Table("test")
private struct TestRecord: Hashable, Sendable {
  @Column(as: UUIDV7.BytesRepresentation.self)
  let id: UUIDV7
}
