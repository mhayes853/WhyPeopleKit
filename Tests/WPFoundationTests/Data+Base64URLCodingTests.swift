import Foundation
import Testing
import WPFoundation

@Suite("Data+Base64URLCoding tests")
struct DataBase64URLCodingTests {
  @Test(
    "String Encoding",
    arguments: [
      ("hello", "aGVsbG8"),
      ("i am bob + i am not bob /\\.\\", "aSBhbSBib2IgKyBpIGFtIG5vdCBib2IgL1wuXA"),
      ("   hello   ", "ICAgaGVsbG8gICA"),
      ("    ", "ICAgIA"),
      ("", ""),
      ("hello = world", "aGVsbG8gPSB3b3JsZA")
    ]
  )
  func encode(plain: String, expected: String) {
    let encodedString = Data(plain.utf8).base64URLEncodedString()
    #expect(encodedString == expected)
  }

  @Test(
    "String Decoding",
    arguments: [
      ("hello", "aGVsbG8"),
      ("i am bob + i am not bob /\\.\\", "aSBhbSBib2IgKyBpIGFtIG5vdCBib2IgL1wuXA"),
      ("   hello   ", "ICAgaGVsbG8gICA"),
      ("    ", "ICAgIA"),
      ("", ""),
      ("hello = world", "aGVsbG8gPSB3b3JsZA")
    ]
  )
  func decode(plain: String, encoded: String) throws {
    let data = try #require(Data(base64URLEncoded: encoded))
    #expect(String(data: data, encoding: .utf8) == plain)
  }
}
