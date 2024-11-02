import Testing

@Suite("MainActor+RunAssumingIsolation tests")
struct MainActorRunAssumingIsolationTests {
  @Test("Does not crash when running on main actor")
  @MainActor
  func runMainActor() {
    let result = MainActor.runAssumingIsolation { true }
    #expect(result == true)
  }
}
