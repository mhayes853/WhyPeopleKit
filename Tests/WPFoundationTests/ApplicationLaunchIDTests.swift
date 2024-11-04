import Testing
import WPFoundation

@Suite("ApplicationLaunchID tests")
struct ApplicationLaunchIDTests {
  @Test("Same ID for same Test Case")
  func sameID() {
    let id1 = ApplicationLaunchID.current()
    let id2 = ApplicationLaunchID.current()
    #expect(id1 == id2)
  }

  #if DEBUG
    @Test("Reset ID")
    func reset() {
      let id = UUIDV7()
      ApplicationLaunchID.withNewValue(id) {
        #expect(ApplicationLaunchID.current().rawValue == id)
      }
    }
  #endif
}
