#if canImport(GRDB)
  import WPGRDB
  import Testing
  import CustomDump

  @Suite("DatabaseFunction+Xoshiro256 tests")
  struct DatabaseFunctionXoshiro256Tests {
    @Test(
      "Select Random Order",
      arguments: [
        (
          UInt64(1000),
          [
            Int64(-1_123_474_578_465_463_384),
            Int64(-5_165_028_823_984_228_053),
            Int64(-396_171_110_791_196_661),
            Int64(-7_415_277_509_587_252_045),
            Int64(5_822_601_199_722_486_907)
          ]
        ),
        (
          UInt64(0),
          [
            Int64(7_890_645_227_428_802_822),
            Int64(-3_230_931_592_057_312_437),
            Int64(-7_358_429_228_471_935_480),
            Int64(-7_117_593_791_869_704_606),
            Int64(-7_012_076_220_203_366_429)
          ]
        )
      ]
    )
    func selectRandomOrder(seed: UInt64, expected: [Int64]) async throws {
      let sqlite = try DatabaseQueue(path: .inMemory)
      try await sqlite.write { $0.add(function: .xoshiro256) }
      let values = try await sqlite.read { db in
        try (0..<5)
          .map { _ in
            try Int64.fetchOne(db, sql: "SELECT XOSHIRO256(?)", arguments: [seed])!
          }
      }
      expectNoDifference(values, expected)
    }
  }
#endif
