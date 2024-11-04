#if canImport(GRDB)
  @preconcurrency import GRDB
  import WPFoundation

  extension DatabaseFunction {
    /// A SQL Function that performs PRNG generations using a seed and Xoshiro256.
    public static let xoshiro256: DatabaseFunction = {
      let rngs = Lock([RandomGenerationSeed: Xoshiro256]())
      return DatabaseFunction(
        "XOSHIRO256",
        argumentCount: 1,
        pure: false,
        function: { args in
          guard let seed = RandomGenerationSeed.fromDatabaseValue(args[0]) else {
            return nil
          }
          return rngs.withLock {
            Int64(truncatingIfNeeded: $0[seed, default: Xoshiro256(seed: seed)].next())
          }
        }
      )
    }()
  }
#endif
