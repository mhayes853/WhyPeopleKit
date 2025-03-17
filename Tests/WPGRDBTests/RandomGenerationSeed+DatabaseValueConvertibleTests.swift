#if canImport(WPGRDB)
  import WPGRDB
  import WPFoundation
  import Testing

  @Suite("RandomGenerationSeed+DatabaseValueConvertible tests")
  struct RandomGenerationSeedDatabaseValueConvertibleTests {
    @Test(
      "To and From Database Value",
      arguments: [1, UInt64.max, 18_729_723, 0xFE_2827_7AB2_7839]
    )
    func toAndFrom(_ x: UInt64) {
      let seed = RandomGenerationSeed(rawValue: x)
      #expect(seed == RandomGenerationSeed.fromDatabaseValue(seed.databaseValue))
    }

    @Test(
      "From Integer",
      arguments: [
        (-1 as Int64, RandomGenerationSeed(rawValue: UInt64.max)),
        (Int64.max, RandomGenerationSeed(rawValue: UInt64(Int64.max))),
        (42 as Int64, RandomGenerationSeed(rawValue: 42))
      ]
    )
    func fromInteger(x: Int64, seed: RandomGenerationSeed) {
      #expect(seed == RandomGenerationSeed.fromDatabaseValue(x.databaseValue))
    }
  }
#endif
