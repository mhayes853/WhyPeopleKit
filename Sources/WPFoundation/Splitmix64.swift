/// The splitmix64 algorithm.
///
/// - Parameter x: An integer.
/// - Returns: An integer.
@inlinable
public func splitmix64(_ x: UInt64) -> UInt64 {
  var z = (x &+ 0x9e37_79b9_7f4a_7c15)
  z = (z ^ (z &>> 30)) &* 0xbf58_476d_1ce4_e5b9
  z = (z ^ (z &>> 27)) &* 0x94d0_49bb_1331_11eb
  return z ^ (z &>> 31)
}
