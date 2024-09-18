import Testing
import WPFoundation

@Suite("SetAlgebra+Toggle tests")
struct SetAlgebraToggleTests {
  @Test("Toggle on")
  func toggleOn() async throws {
    var set = Set<Int>([1, 2, 3])
    set.toggle(4)
    #expect(set == [1, 2, 3, 4])
  }

  @Test("Toggle off")
  func toggleOff() async throws {
    var set = Set<Int>([1, 2, 3])
    set.toggle(3)
    #expect(set == [1, 2])
  }
}
