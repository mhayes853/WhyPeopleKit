// MARK: - Xoshiro256

/// A `RandomNumberGenerator` based on Xoshiro256.
public struct Xoshiro256 {
  @usableFromInline
  var _state: (UInt64, UInt64, UInt64, UInt64)

  /// Creates a Xoshiro256 from the specified state.
  ///
  /// - Parameter state: The initial state.
  @inlinable
  public init(state: (UInt64, UInt64, UInt64, UInt64)) {
    self._state = state
    self._state.0 = splitmix64(self._state.0)
    self._state.1 = splitmix64(self._state.1)
    self._state.2 = splitmix64(self._state.2)
    self._state.3 = splitmix64(self._state.3)
  }
}

// MARK: - Seed Initializers

extension Xoshiro256 {
  /// Creates a Xoshiro256 from a ``RandomGenerationSeed``.
  ///
  /// - Parameter seed: A ``RandomGenerationSeed``.
  public init(seed: RandomGenerationSeed = RandomGenerationSeed()) {
    self.init(state: (seed.rawValue, 18_446_744, 73709, 551615))
  }

  /// Creates a Xoshiro256 from a singular integer seed.
  ///
  /// - Parameter seed: An integer.
  public init(seed: UInt64) {
    self.init(seed: RandomGenerationSeed(rawValue: seed))
  }
}

// MARK: - State

extension Xoshiro256 {
  /// The current state of this generator.
  public var state: (UInt64, UInt64, UInt64, UInt64) {
    self._state
  }
}

// MARK: - RandomNumberGenerator

extension Xoshiro256: RandomNumberGenerator {
  @inlinable
  public mutating func next() -> UInt64 {
    let result = _rotl(self._state.0 &+ self._state.3, 23) &+ self._state.0
    let t = self._state.1 &<< 17
    self._state.2 ^= self._state.0
    self._state.3 ^= self._state.1
    self._state.1 ^= self._state.2
    self._state.0 ^= self._state.3
    self._state.2 ^= t
    self._state.3 = _rotl(self._state.3, 45)
    return result
  }
}

// MARK: - Helpers

@usableFromInline
func _rotl(_ x: UInt64, _ k: Int) -> UInt64 {
  (x &<< k) | (x &>> (64 &- k))
}
