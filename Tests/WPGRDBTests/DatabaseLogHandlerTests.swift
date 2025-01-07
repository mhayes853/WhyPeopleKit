#if canImport(GRDB)
  import CustomDump
  import Logging
  import Synchronization
  import Testing
  import WPFoundation
  import WPGRDB

  @Suite("DatabaseLogHandler tests")
  struct DatabaseLogHandlerTests {
    @Test("Persists Logs To Database")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func persists() async throws {
      let (stream, continuation) = AsyncStream<Void>.makeStream()
      var iterator = stream.makeAsyncIterator()
      var handler = DatabaseLogHandler(label: "test", path: .inMemory)
      handler.metadata["prior"] = "one"
      handler.metadata["after"] = "two"
      handler.onLogPersisted = { _ in continuation.yield() }
      let logger = Logger(label: "test") { _ in handler }
      let metadata: Logger.Metadata = [
        "prior": "zero",
        "key": "value",
        "k2": .stringConvertible(123),
        "array": ["one", "two"],
        "dict": ["one": .stringConvertible(1), "two": .stringConvertible(true)],
        "codable": .stringConvertible(SomeCodable(num: 1)),
        "stringConvertible": .stringConvertible(SomeStringConvertible(description: "hello"))
      ]
      logger.log(
        level: .error,
        "Something bad happened",
        metadata: metadata
      )
      await iterator.next()
      let logs = try await handler.all()
      try #require(logs.count == 1)
      #expect(logs[0].label == "test")
      #expect(logs[0].level == .error)
      #expect(logs[0].message == "Something bad happened")

      let expectedMetadata: Logger.Metadata = [
        "prior": "zero",
        "after": "two",
        "key": "value",
        "k2": "123",
        "array": ["one", "two"],
        "dict": ["one": "1", "two": "true"],
        "codable": "1",
        "stringConvertible": "hello"
      ]
      expectNoDifference(logs[0].loggerMetadata, expectedMetadata)
    }

    @Test("Purges Logs Older than the Specified Lifetime")
    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    func purges() async throws {
      let (stream, continuation) = AsyncStream<Void>.makeStream()
      var iterator = stream.makeAsyncIterator()
      let currentDate = Lock(Date(staticISO8601: "2024-06-11T00:00:00+0000"))
      var handler = DatabaseLogHandler(
        label: "test",
        path: .inMemory,
        rotatingEvery: .weeks(2),
        date: { currentDate.withLock { $0 } }
      )
      handler.onLogPersisted = { _ in continuation.yield() }
      let logger = Logger(label: "test") { _ in handler }

      logger.log(level: .error, "Something bad happened")
      await iterator.next()

      currentDate.withLock { $0 = Date(staticISO8601: "2024-06-27T00:00:00+0000") }
      logger.log(level: .error, "Another bad happened")
      await iterator.next()

      let logs = try await handler.all()
      try #require(logs.count == 1)
      #expect(logs[0].message == "Another bad happened")
    }
  }

  private struct SomeCodable: Codable, CustomStringConvertible {
    let num: Int

    var description: String {
      self.num.description
    }
  }

  private struct SomeStringConvertible: CustomStringConvertible {
    var description: String
  }

#endif
