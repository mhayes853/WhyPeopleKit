import Testing
import WPFoundation

@Suite("Xoshiro256 tests")
struct Xoshiro256Tests {
  @Test(
    "Random Values",
    arguments: [
      (
        UInt64(0),
        [
          UInt64(7_890_645_227_428_802_822),
          UInt64(15_215_812_481_652_239_179),
          UInt64(11_088_314_845_237_616_136),
          UInt64(11_329_150_281_839_847_010),
          UInt64(11_434_667_853_506_185_187)
        ]
      ),
      (
        UInt64(1000),
        [
          UInt64(17_323_269_495_244_088_232),
          UInt64(13_281_715_249_725_323_563),
          UInt64(18_050_572_962_918_354_955),
          UInt64(11_031_466_564_122_299_571),
          UInt64(5_822_601_199_722_486_907)
        ]
      )
    ]
  )
  func randomValues(seed: UInt64, expected: [UInt64]) async throws {
    var generator = Xoshiro256(seed: seed)
    let values = (0..<expected.count).map { _ in generator.next() }
    #expect(values == expected)
  }
}
