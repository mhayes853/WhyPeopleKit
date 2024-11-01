#if canImport(GRDB)
  import Foundation
  import Testing
  import WPGRDB

  @Suite("DatabasePath tests")
  struct DatabasePathTests {
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    init() {
      try? FileManager.default.removeItem(at: .directoryURL)
    }

    @Test(
      "Open DatabaseQueue",
      arguments: [DatabasePath.inMemory, .inMemory(named: "Test"), .url(.dbURL)]
    )
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func openQueue(path: DatabasePath) {
      #expect(throws: Never.self) {
        _ = try DatabaseQueue(path: path)
      }
    }

    @Test("Open DatabasePool", arguments: [DatabasePath.url(.dbURL)])
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func openPool(path: DatabasePath) {
      #expect(throws: Never.self) {
        _ = try DatabasePool(path: path)
      }
    }
  }

  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  extension URL {
    fileprivate static let directoryURL = Self.documentsDirectory.appending(
      path: "grdb-test/nested"
    )
    fileprivate static let dbURL = Self.directoryURL.appending(path: "test.db")
  }
#endif
