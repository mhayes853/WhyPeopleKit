import Foundation
import Testing
import WPGRDB

@Suite("DatabasePath tests")
struct DatabasePathTests {
  private let directoryURL = URL.documentsDirectory.appending(path: "grdb-test/nested")
  private let url = URL.documentsDirectory.appending(path: "grdb-test/nested/test.db")

  init() {
    try? FileManager.default.removeItem(at: .directoryURL)
  }

  @Test(
    "Open DatabaseQueue",
    arguments: [DatabasePath.inMemory, .inMemory(named: "Test"), .url(.dbURL)]
  )
  func openQueue(path: DatabasePath) {
    #expect(throws: Never.self) {
      _ = try DatabaseQueue(path: path)
    }
  }

  @Test("Open DatabasePool", arguments: [DatabasePath.url(.dbURL)])
  func openPool(path: DatabasePath) {
    #expect(throws: Never.self) {
      _ = try DatabasePool(path: path)
    }
  }
}

extension URL {
  fileprivate static let directoryURL = Self.documentsDirectory.appending(path: "grdb-test/nested")
  fileprivate static let dbURL = Self.directoryURL.appending(path: "test.db")
}
