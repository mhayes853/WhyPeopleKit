import WPFoundation
import Testing

@Suite("Data+HexEncodedString tests")
struct DataHexEncodedStringTests {
  @Test(
    "Hex Encoded String",
    arguments: [
      (Data("hello".utf8), "68656c6c6f"),
      (Data("Hello, World!".utf8), "48656c6c6f2c20576f726c6421")
    ]
  )
  func hex(data: Data, hex: String) async throws {
    #expect(data.hexEncodedString() == hex)
  }
}
