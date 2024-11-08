import Testing
import WPFoundation

@Suite("StaticID tests")
struct StaticIDTests {
  @Test("Encoding")
  func encoding() throws {
    let data = try JSONEncoder().encode(StaticID())
    #expect(String(data: data, encoding: .utf8) == "1")
  }

  @Test(
    "Decoding",
    arguments: [
      ("\"hello\"", nil),
      ("1", StaticID()),
      ("\"1\"", nil),
      ("2", nil),
      ("true", nil)
    ]
  )
  func decode(string: String, id: StaticID?) {
    let value = try? JSONDecoder().decode(StaticID.self, from: Data(string.utf8))
    #expect(value == id)
  }
}
